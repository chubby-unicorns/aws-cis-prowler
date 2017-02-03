#!/bin/bash	
# VERSION HISTORY:
	# v1.0 - only output the command to run.

# TO DO:
	# add steps to output the report URL somehow?

STACK_NAME=CISProwler # the cfn stack will take this name; the template needs to be called the same
PROFILE=default #aws cli profile name to pass to _setAWSenv.sh
# KEY_NAME=<ENTER YOUR KEYNAME HERE> # enter your keyname here - ONLY IF NEEDED (template v1.0+ does not require a key)
# STACK_OWNER="<ENTER YOUR NAME HERE>" # ENTER YOUR NAME HERE - command will fail without.

setenv(){
	. _setAWSenv.sh $PROFILE
}
setenvecho(){
	echo ". _setAWSenv.sh $PROFILE"
}

launchstack(){
	echo Launching stack $STACK_NAME...
	aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://cfn/$STACK_NAME.yaml --capabilities CAPABILITY_NAMED_IAM --tags Key=StackOwner,Value=$STACK_OWNER # --parameters  ParameterKey=KeyPair,ParameterValue=$KEY_NAME
}
launchstackecho(){
	echo "aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://cfn/$STACK_NAME.yaml --capabilities CAPABILITY_NAMED_IAM --tags Key=StackOwner,Value=$STACK_OWNER # --parameters  ParameterKey=KeyPair,ParameterValue=$KEY_NAME"
}

waitstack(){
	echo "aws cloudformation wait stack-create-complete --stack-name $STACK_NAME | grep Reason"
	# aws cloudformation wait stack-create-complete --stack-name $STACK_NAME | grep Reason
}

stackevents(){
	echo "aws cloudformation describe-stack-events --stack-name $STACK_NAME  | grep Reason"
	# aws cloudformation describe-stack-events --stack-name $STACK_NAME  | grep Reason
}

describestack(){
	echo "aws cloudformation describe-stacks --stack-name $STACK_NAME --out table"
	# aws cloudformation describe-stacks --stack-name $STACK_NAME --out table
}

stackresources(){
	echo "aws cloudformation describe-stack-resources --stack-name $STACK_NAME --out table --query \"StackResources[].{LogicalResourceId:LogicalResourceId,PhysicalResourceId:PhysicalResourceId,ResourceStatus:ResourceStatus,ResourceType:ResourceType,StackName:StackName,Timestamp:Timestamp}\""
	# aws cloudformation describe-stack-resources --stack-name $STACK_NAME --out table
}

killstack(){
	echo "aws cloudformation delete-stack --stack-name $STACK_NAME"
	echo "aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME ;echo done"
	# echo Destroying stack $STACK_NAME... ;aws cloudformation delete-stack --stack-name $STACK_NAME; aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME ; echo done
}
# launchstack

clear;echo run these commands:
setenvecho
launchstackecho
waitstack
stackevents
describestack
stackresources
killstack
