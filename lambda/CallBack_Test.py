import boto3
import logging
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB client and table
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CallBack_Shiva')  # Replace 'your_table_name' with your DynamoDB table name

def insert_callback_number(callback_number, queue_name, initial_contact_id):
    """
    Insert a callback number into DynamoDB table with current UTC timestamp.
    """
    current_time_epoch = int(datetime.utcnow().timestamp())
    expire_at_epoch = current_time_epoch + 3600  # 60 minutes from current time
    table.put_item(Item={
        'CallBack_Number': callback_number,
        'CreatedAt': current_time_epoch,
        'ExpireAt': expire_at_epoch,
        'Date (UTC)': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),
        'QueueName': queue_name,
        'InitialContactId': initial_contact_id
    })
    
def delete_callback_number(callback_number):
    """
    Delete a callback number from DynamoDB table.
    """
    table.delete_item(Key={'CallBack_Number': callback_number})

def lambda_handler(event, context):
    # Log the incoming event
    logger.info("Incoming event: %s", event)
    
    try:
        # Extract InitiationMethod & InitialContactId from the event
        initiation_method = event['Details']['ContactData']['InitiationMethod']
        initial_contact_id = event['Details']['ContactData']['InitialContactId']
        
        # Log the initiation method
        logger.info("Initiation Method: %s", initiation_method)
        
        # Extract CallBack_Number from the event attributes
        callback_number = event['Details']['ContactData']['Attributes'].get('CallBack_Number')
        
        # Extract QueueName from the event
        queue_name = event['Details']['ContactData']['Queue']['Name']
        
        # Log the extracted callback number
        logger.info("Extracted Callback Number: %s", callback_number)
        
        if initiation_method == 'INBOUND':
            # Check if callback_number exists in DynamoDB
            response = table.get_item(Key={'CallBack_Number': callback_number})
            
            if 'Item' not in response:
                # If callback_number not found, insert it into DynamoDB and set CallBack_OptIn
                insert_callback_number(callback_number, queue_name, initial_contact_id)
                present_status = 'no'  # Because it's not found, we set present status to 'no'
                call_back_opt_in = 'CallBack request placed successfully'
            else:
                # If callback_number found, return the present status
                present_status = 'yes'
                call_back_opt_in = ''
            
            # Log the present status
            logger.info("Present Status: %s", present_status)
            
            # Return the callback number, present status, and CallBack_OptIn
            return {
                'CallBack_Number': callback_number,
                'Present': present_status,
                'CallBack_OptIn': call_back_opt_in
            }
        
        elif initiation_method == 'CALLBACK':
            # Check if callback_number exists in DynamoDB
            response = table.get_item(Key={'CallBack_Number': callback_number})
            
            if 'Item' in response:
                # If callback_number found, delete it from DynamoDB
                delete_callback_number(callback_number)
                result_message = "The existing callback request removed and callback is initiated"
                cb_request_deleted = 'yes'
            else:
                # If callback_number not found, return present=no
                result_message = "Callback number not found"
                cb_request_deleted = 'not found'
            
            # Log the result message
            logger.info(result_message)
            
            # Return the result message and cb_request_deleted attribute
            return {
                'message': result_message,
                'CBRequest_Deleted': cb_request_deleted
            }
    
    except KeyError as e:
        # Log missing attribute error
        logger.error(f"Error: {e}")
        
        # Return error response
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: {e}")
        }
    
    except Exception as e:
        # Log any other errors
        logger.error("Error: %s", str(e))
        
        # Return error response
        return {
            'statusCode': 400,
            'body': str(e)
        }
