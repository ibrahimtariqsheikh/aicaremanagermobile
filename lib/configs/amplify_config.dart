import 'package:flutter_dotenv/flutter_dotenv.dart';

final poolId = dotenv.env["AWS_COGNITO_USER_POOL_ID"];
final appClientId = dotenv.env["AWS_COGNITO_USER_POOL_CLIENT_ID"];
final region = dotenv.env["AWS_COGNITO_REGION"];



final amplifyConfig = ''' {
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "$poolId",
            "AppClientId": "$appClientId",
            "Region": "ap-south-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "usernameAttributes": ["email"],
            "signupAttributes": [
              "email", "name"
            ],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": []
            }
          }
        }
      }
    }
  }
}''';
