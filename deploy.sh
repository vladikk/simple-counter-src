if [ "$#" -ne 3 ]
then
  echo "Usage: ./deploy.sh \"stack-name\" \"aws-region\" \"aws-profile\""
  exit 1
fi

stack_name=$1
aws_region=$2
aws_profile=$3

echo "---------------------"
echo "Stack: $stack_name"
echo "Region: $aws_region"
echo "Profile: $aws_profile"
echo "---------------------"

# Reset the logs directory
logs_path="./logs"
log_path="$logs_path/out.log"
err_log_path="$logs_path/err.log"

rm -rf logs
mkdir logs

echo "Deploying cloudformation stack '$stack_name'"
aws cloudformation deploy \
	--template-file "src/cloudformation.yml" \
	--stack-name "$stack_name" \
	--capabilities CAPABILITY_IAM \
	--region "$aws_region" \
	--profile $aws_profile \
	>>$log_path 2>>$err_log_path

if [ $? -eq 0 ]
then
  echo "Successfully created/updated the cloudformation stack: '$stack_name'"
else
  echo "Cloudformation update failed. See '$err_log_path' for details." >&2
  exit 1
fi

# Reset the clients directory for the current stack
rm -rf ./clients/$stack_name
mkdir ./clients/$stack_name

echo "Fetching the stack's output values"

public_url=$(aws cloudformation describe-stacks \
	--profile $aws_profile \
	--region "$aws_region" \
	--stack-name "$stack_name" \
	--query 'Stacks[0].Outputs[?OutputKey==`PublicUrl`].OutputValue' \
	--output text) >>$log_path 2>>$err_log_path

api_id=$(aws cloudformation describe-stacks \
	--profile $aws_profile \
	--region "$aws_region" \
	--stack-name "$stack_name" \
	--query 'Stacks[0].Outputs[?OutputKey==`ApiId`].OutputValue' \
	--output text) >>$log_path 2>>$err_log_path

stage_name=$(aws cloudformation describe-stacks \
	--profile $aws_profile \
	--region "$aws_region" \
	--stack-name "$stack_name" \
	--query 'Stacks[0].Outputs[?OutputKey==`StageName`].OutputValue' \
	--output text) >>$log_path 2>>$err_log_path

echo "Generating Swagger documents(json and yaml)"

json_swagger_path="./clients/$stack_name/swagger.json"
yaml_swagger_path="./clients/$stack_name/swagger.yaml"

aws apigateway get-export \
    --profile $aws_profile \
	--rest-api-id $api_id \
	--stage-name $stage_name \
	--accepts application/json \
	--export-type swagger \
	$json_swagger_path \
	>>$log_path 2>>$err_log_path

aws apigateway get-export \
    --profile $aws_profile \
	--rest-api-id $api_id \
	--stage-name $stage_name \
	--accepts application/yaml \
	--export-type swagger \
	$yaml_swagger_path \
	>>$log_path 2>>$err_log_path

client_languages=( "php" "csharp" "python" "java" "javascript" "ruby" "bash" "go" "perl" "typescript-angular2" "aspnetcore" )
for client_lang in "${client_languages[@]}"
do
	printf "Generating client library for $client_lang..."
	java -jar ./tools/swagger-codegen.jar generate \
		-i $yaml_swagger_path \
		-l $client_lang \
		-o clients/$stack_name/$client_lang \
		-c tools/swagger-codegen.config \
		>>$log_path 2>>$err_log_path
	pushd ./clients/$stack_name > /dev/null
	zip -r $client_lang.zip $client_lang >>../../$log_path 2>>../../$err_log_path
	popd > /dev/null
	rm -rf clients/$stack_name/$client_lang >>$log_path 2>>$err_log_path
	printf "done\n"
done

echo "Finished. Service URL: $public_url"
