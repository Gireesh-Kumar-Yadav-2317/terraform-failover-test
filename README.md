**AWS Failover Testing – Runbook / README**

This document provides step-by-step instructions to perform **failover testing** for an application deployed on AWS using an Application Load Balancer (ALB), Auto Scaling Group (ASG), and EC2 instances in private subnets.

**Architecture Overview**

 Application Load Balancer (ALB)
 Target Group: `<target_group_arn>`
 Auto Scaling Group: `<asg_name>`
 EC2 Instances in private subnets
 NAT Gateway (required for package installation)

**Prerequisites**

Ensure the following before testing:

 EC2 instances are **healthy** in target group
 ALB DNS is accessible
 Auto Scaling Group is in **InService state**
 NAT Gateway is configured if instances are in private subnet

**ALB URL**

http://<alb_dns_name>


Step 1: Verify Target Health

aws elbv2 describe-target-health \
  --target-group-arn <target_group_arn> \
  --region <region>

Excepted 

healthy
healthy`


Step 2: Continuous Curl Monitoring

Run this in Terminal 1:

while true; do
  echo "===== $(date) ====="
  curl -s http://<alb_dns_name>
  echo
  sleep 2
done

Expected:

Responses alternate between EC2 instances
Example output:

  OK - ip-10-0-x-x

**Step 3: Monitor Target Health (Terminal 2)**

watch -n 5 '
aws elbv2 describe-target-health \
  --target-group-arn <target_group_arn> \
  --region <region> \
  --query "TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]" \
  --output table
'


**Step 4: Monitor Auto Scaling Group (Terminal 3)**

watch -n 5 '
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names <asg_name> \
  --region <region> \
  --query "AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState,HealthStatus]" \
  --output table
'

**Step 5: Simulate Failure (Terminate Instance)**

Choose one instance from target group and terminate it:

aws ec2 terminate-instances \
  --instance-ids <instance_id> \
  --region <region>


**Step 6: Observe Failover Behavior**

During failure:

ALB continues serving traffic
Requests are routed to remaining healthy instance
ASG launches replacement instance automatically

Expected transition:

draining -> terminated -> new instance launched -> healthy


Step 7: Validate Recovery

Run target health again:


aws elbv2 describe-target-health \
  --target-group-arn <target_group_arn> \
  --region <region>


Expected:

healthy
healthy

Step 8: End Test

Stop all monitoring:


**Success Criteria**

Failover test is successful if:

* No downtime observed during instance termination
* ALB continues serving traffic
* ASG automatically replaces failed instance
* New instance passes health checks

 Notes

* Ensure NAT Gateway exists for private subnet instances
* Ensure security group allows port 80 from ALB
* Ensure health check path is `/`


**Placeholders Used**

* `<alb_dns_name>`
* `<target_group_arn>`
* `<asg_name>`
* `<instance_id>`
* `<region>`



