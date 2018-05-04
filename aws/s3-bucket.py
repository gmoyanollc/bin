#!/usr/bin/python

import boto3
import sys
import botocore

action = sys.argv[1]
bucket_name = sys.argv[2]
file_name = sys.argv[3]
version_id = sys.argv[4]

s3_client = boto3.client("s3")

if action == "create-bucket":
  print "  creating bucket"
  s3_client.create_bucket(Bucket=bucket_name)

s3_resource = boto3.resource("s3")

if action == "delete-bucket":
  print "  deleting bucket"
  try:
     bucket = s3_resource.Bucket(bucket_name)

     for key in bucket.objects.all():
       key.delete()

     bucket.delete()

  except botocore.exceptions.ClientError as e:
    print "  " + e.response["Error"]["Code"]

if action == "upload-object":
  print "  uploading object"
  s3_resource.Object(bucket_name, file_name).put(Body=open(file_name, 'r'))

if action == "delete-object":
  print "  deleting object"
  s3_resource.Object(bucket_name, file_name).delete(version_id)
