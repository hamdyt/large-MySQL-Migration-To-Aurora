# large-MySQL-Migration-To-Aurora

This project demonstratea real use case of migrating 50,000 MySQL databases with 1.5 million tables and LOB (large data objects) to Amazon Aurora using a combination of AWS Database Migration Service, SCT, EC2, S3, Lambda and DynamoDB. 

Large scale database migration is difficult, multiphase and time consuming. Customers want a simpler way to achieve large scale migration with little to no downtime. The attached assets In this repo should help you with large scale migrations to Amazon Aurora MySql database. The assets are as follows:

The following architecture diagram depicts the end to end migration flow

![image](https://user-images.githubusercontent.com/20010017/144901355-8c2cae45-23de-4971-9ecf-a588571df712.png)


# Deployment Instructions
- The MigrationStack.yaml is the main stack which contains the other nested stack.
- APIGatewayWithLambda.yaml: This stack creates an API Gateway deployment, a Lambda function for bulk migration processing and a CloudWatch log Group
- DynamoDB.yaml: the stack creates a DynamoDB to persist the migrated databases meta data
- EC2Instance_Producer.yaml: This stack creates an EC2 insatnce that acts as a producer to upload the database files into S3 to be ready for migration.
- EC2Instance_Consumer.yaml: This stack creates an EC2 instance that Check Aurora for active database connections and importing databases in Aurora using MySQL import by     downloading the sql file from S3 
- RDS_MySql.yaml: This stack creates an Amazon Aurora RDS instance to host migrated databases.
- S3WithLambdaTrigger.yaml: this stack creates an S3 bucket to host the database files and a Lambda Event trigger on PUT of new objects on S3. This lambda stores the metadata of the sql output file in DynamoDB
- The .sh files are used for import/export of MySQL dump files

# Important
- In the main MigrationStack.yaml, for every stack you will need to replace its relevant S3 object path. 
- For example - 
  Consider the following stack on MigrationStack.yaml. The templateURL will be the S3 object path that you will get once you upload APIGatewayWithLambda.yaml to your S3 bucket.

  APIGatewayWithLambda:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: 'https://cloudformation-stacks-bucket-apn.s3.us-east-2.amazonaws.com/APIGatewayWithLambda.yaml'   <-------- Change this for your S3 bucket
