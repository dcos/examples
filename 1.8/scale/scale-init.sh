#!/usr/bin/env sh

# The following environment variables are required for the successful execution of this script.
# DCOS_TOKEN: DCOS token that can found within ~/.dcos/dcos.toml once DCOS CLI is authenticated against DCOS cluster
# DCOS_ROOT_URL: The externally routable Admin URL.
# REGION_NAME: AWS Region where SQS and S3 bucket reside.
# BUCKET_NAME: AWS S3 bucket name only. Full ARN should NOT be used.
# QUEUE_NAME: AWS SQS queue name only. Full ARN should NOT be used.
# ACCESS_KEY: Access Key for IAM user that will access S3 and SQS resources.
# SECRET_KEY: Secret Key for IAM user that will access S3 and SQS resources.

cat << EOF > workspace.json
{
    "description": "s3-direct",
    "json_config": {
        "broker": {
            "bucket_name": "${BUCKET_NAME}",
            "credentials": {
                "access_key_id": "${ACCESS_KEY}",
                "secret_access_key": "${SECRET_KEY}"
            },
            "region_name": "${REGION_NAME}",
            "type": "s3"
        }
    },
    "name": "s3-direct",
    "title": "s3-direct",
    "base_url": "https://s3.amazonaws.com/${BUCKET_NAME}"
}
EOF

JOB_ARGS="1024 \${input_file} \${job_output_dir}"
cat << EOF > job-type.json
{
    "name": "read-bytes",
    "version": "1.0.0",
    "title": "Read Bytes",
    "description": "Reads x bytes of an input file and writes to output dir",
    "category": "testing",
    "author_name": "John_Doe",
    "author_url": "http://www.example.com",
    "is_operational": true,
    "icon_code": "f27d",
    "docker_privileged": false,
    "docker_image": "geoint/read-bytes",
    "priority": 230,
    "timeout": 3600,
    "max_scheduled": null,
    "max_tries": 3,
    "cpus_required": 1.0,
    "mem_required": 1024.0,
    "disk_out_const_required": 0.0,
    "disk_out_mult_required": 0.0,
    "interface": {
        "output_data": [
            {
                "media_type": "application/octet-stream",
                "required": true,
                "type": "file",
                "name": "output_file"
            }
        ],
        "shared_resources": [],
        "command_arguments": "${JOB_ARGS}",
        "input_data": [
            {
                "media_types": [
                    "application/octet-stream"
                ],
                "required": true,
                "partial": true,
                "type": "file",
                "name": "input_file"
            }
        ],
        "version": "1.1",
        "command": ""
    },
    "error_mapping": {
        "version": "1.0",
        "exit_codes": {}
    },
    "trigger_rule": null
}
EOF

cat << EOF > recipe-type.json
{
    "definition": {
        "input_data": [
            {
                "media_types": [
                    "application/octet-stream"
                ],
                "name": "input_file",
                "required": true,
                "type": "file"
            }
        ],
        "jobs": [
            {
                "dependencies": [],
                "job_type": {
                    "name": "read-bytes",
                    "version": "1.0.0"
                },
                "name": "read-bytes",
                "recipe_inputs": [
                    {
                        "job_input": "input_file",
                        "recipe_input": "input_file"
                    }
                ]
            }
        ]
    },
    "description": "Read x bytes from input file and save in output dir",
    "name": "read-byte-recipe",
    "title": "Read Byte Recipe",
    "trigger_rule": {
        "configuration": {
            "condition": {
                "data_types": [],
                "media_type": ""
            },
            "data": {
                "input_data_name": "input_file",
                "workspace_name": "s3-direct"
            }
        },
        "is_active": true,
        "name": "read-byte-trigger",
        "type": "INGEST"
    },
    "version": "1.0.0"
}
EOF

cat << EOF > strike.json
{
  "name": "s3-strike-process",
  "title": "s3-strike-process",
  "description": "s3-strike-process",
  "configuration": {
    "version": "2.0",
    "workspace": "s3-direct",
    "monitor": {
      "type": "s3",
      "sqs_name": "${QUEUE_NAME}",
      "credentials": {
        "access_key_id": "${ACCESS_KEY}",
        "secret_access_key": "${SECRET_KEY}"
      },
      "region_name": "${REGION_NAME}"
    },
    "files_to_ingest": [
      {
        "filename_regex": ".*",
        "data_types": [
          "all_my_mounted_files"
        ]
      }
    ]
  }
}
EOF


curl -X POST -H "Authorization: token=${DCOS_TOKEN}" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d @workspace.json "${DCOS_ROOT_URL}/service/scale/api/v4/workspaces/"
curl -X POST -H "Authorization: token=${DCOS_TOKEN}" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d @job-type.json "${DCOS_ROOT_URL}/service/scale/api/v4/job-types/"
curl -X POST -H "Authorization: token=${DCOS_TOKEN}" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d @recipe-type.json "${DCOS_ROOT_URL}/service/scale/api/v4/recipe-types/"
curl -X POST -H "Authorization: token=${DCOS_TOKEN}" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d @strike.json "${DCOS_ROOT_URL}/service/scale/api/v4/strikes/"

