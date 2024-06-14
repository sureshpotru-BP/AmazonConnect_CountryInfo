import boto3

# Create DynamoDB client
dynamodb = boto3.client('dynamodb')

def parse_country_info(country_code):
    # Retrieve data from DynamoDB
    response = dynamodb.get_item(
        TableName='Country_Info',
        Key={'CountryCode': {'S': country_code}}
    )

    # Check if 'Item' exists in response
    if 'Item' in response:
        # Extracting values from DynamoDB response
        country_code_iso = response['Item']['CountryCodeISO']['S']
        country_origin = response['Item']['CountryOrigin']['S']
        return country_code_iso, country_origin
    else:
        return None, None

def lambda_handler(event, context):
    # Extracting the country code from the SystemEndpoint address
    system_endpoint = event['Details']['ContactData']['SystemEndpoint']['Address']
    contact_id = event['Details']['ContactData']['ContactId']
    print("The ContactID for the call is:", contact_id)
    
    # Initialize the parsed country code with the first digit of the system endpoint
    parsed_country_code = '+' + system_endpoint[1]
    
    print("Initial parsed country code:", parsed_country_code)
    
    # Check if the parsed country code is a complete country code
    country_code_iso, country_origin = parse_country_info(parsed_country_code)
    
    # If a match is found, return the result
    if country_code_iso:
        print("Found match for country code:", parsed_country_code)
        return {
            "CountryCode": parsed_country_code,
            "CountryCodeISO": country_code_iso,
            "CountryOrigin": country_origin,
            "ExtractedCountryCode": parsed_country_code
        }
    
    # Start the parsing loop from the next character
    for i in range(2, min(6, len(system_endpoint))):  # Limit parsing to maximum 4 characters
        # Try adding one more digit from the system endpoint address
        parsed_country_code += system_endpoint[i]
        
        print("Current parsed country code:", parsed_country_code)
        
        # Query DynamoDB with the parsed country code
        country_code_iso, country_origin = parse_country_info(parsed_country_code)
        
        # Check if we found a match in the DynamoDB table
        if country_code_iso:
            print("Found match for country code:", parsed_country_code)
            return {
                "CountryCode": parsed_country_code,
                "CountryCodeISO": country_code_iso,
                "CountryOrigin": country_origin,
                "ExtractedCountryCode": parsed_country_code
            }
        
        # If the length of the parsed country code exceeds 4 characters, break the loop
        if len(parsed_country_code) >= 4:
            break
    
    # If no match found after 4 iterations or when the length of the parsed country code exceeds 4 characters, return an error
    print("No match found for country code after 4 iterations")
    return {
        "errorMessage": "No data found for the provided country code",
        "errorType": "DataNotFoundError",
        "ExtractedCountryCode": parsed_country_code
    }
