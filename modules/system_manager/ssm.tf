#Create SSM documents
resource "aws_ssm_document" "r_abccompany-CustomPatching" {
  name            = "abccompany-CustomPatching"
  document_format = "YAML"
  document_type   = "Automation"
  content         = <<DOC
${file("./modules/system_manager/Documents/SSM-Documents/abccompany-CustomPatching.yml")}  
DOC  
}

resource "aws_ssm_document" "r_abccompany-CustomPatching-Analysis" {
  name            = "abccompany-CustomPatching-Analysis"
  document_format = "YAML"
  document_type   = "Automation"
  content         = <<DOC
${file("./modules/system_manager/Documents/SSM-Documents/abccompany-CustomPatching-Analysis.yml")}
DOC  
}

resource "aws_ssm_document" "r_abccompany-Nfsmount" {
  name            = "abccompany-Nfsmount"
  document_format = "YAML"
  document_type   = "Automation"
  content         = <<DOC
${file("./modules/system_manager/Documents/SSM-Documents/abccompany-Nfsmount.yml")}
DOC  
}
#Create SSM maintenance window
resource "aws_ssm_maintenance_window" "r_m_window" {
  count                      = length(var.v_system_manager_patch_cycles)
  name                       = var.v_system_manager_patch_cycles[count.index]
  description                = "${var.v_system_manager_patch_cycles[count.index]} Patching Cycle"
  schedule                   = "at(2100-01-01T05:00:00)"
  duration                   = 5
  cutoff                     = 1
  schedule_timezone          = "GMT"
  allow_unassociated_targets = true
  enabled                    = "false"
}
#Create SSM maintenance window task
resource "aws_ssm_maintenance_window_task" "r_m_window_task" {
  count           = length(var.v_system_manager_patch_cycles)
  name            = "Patching_Task"
  description     = "Initiate the patching task"
  max_concurrency = "100%"
  max_errors      = "100%"
  priority        = 1
  task_arn        = aws_lambda_function.r_lambda_SSM_AutomationHandler.arn
  task_type       = "LAMBDA"
  window_id       = aws_ssm_maintenance_window.r_m_window[count.index].id
  targets {
    key    = "InstanceIds"
    values = ["mi-0edfc70cd335a0c79"]
  }

  task_invocation_parameters {
    lambda_parameters {
      payload = jsonencode({
        "WindowId" : "{{WINDOW_ID}}",
        "TaskExecutionId" : "{{TASK_EXECUTION_ID}}",
        "Document" : {
          "Name" : "abccompany-CustomPatching",
          "Version" : "$LATEST",
          "Parameters" : {
            "AutomationAssumeRole" : [
              "${aws_iam_role.r_role_ssm_AutomationAdministrationRole.arn}"
            ],
            "ExecutionTimeout" : ["10800"],
            "SleepTime" : ["PT60S"],
            "SleepTimeReboot" : ["PT180S"],
            "PreWindowCommands" : [
              "if (Test-Path C:\\Scripts\\pre_os_patching.ps1){", " powershell.exe -ExecutionPolicy RemoteSigned -c \". C:\\scripts\\pre_os_patching.ps1\"", "}else {", "\techo \"C:\\Scripts\\pre_os_patching.ps1 does not exist!\"", "\texit 1", "}"
            ],
            "PostWindowCommands" : [
              "if (Test-Path C:\\Scripts\\post_os_patching.ps1){", " powershell.exe -ExecutionPolicy RemoteSigned -c \". C:\\scripts\\post_os_patching.ps1\"", "}else {", "\techo \"C:\\Scripts\\post_os_patching.ps1 does not exist!\"", "\texit 1", "}"
            ],
            "PreLinuxCommands" : [
              "#!/bin/bash",
              "if [ -x /usr/local/patching/pre_os_patching ]; then /usr/local/patching/pre_os_patching; fi"
            ],
            "PostLinuxCommands" : [
              "#!/bin/bash",
              "if [ -x /usr/local/patching/post_os_patching ]; then /usr/local/patching/post_os_patching; fi"
            ],
            "Operation" : [
              "Install"
            ],
            "RebootOption" : ["RebootIfNeeded"],
            "LinuxRebootCommand" : ["shutdown -r +1"],
            "WindowsRebootCommand" : ["C:\\WINDOWS\\system32\\shutdown.exe /r /f /t 60"]
          }
        },
        "TargetParameterName" : "InstanceIds",
        "Targets" : [
          {
            "Key" : "ResourceGroup",
            "Values" : [
              "${var.v_system_manager_patch_cycles[count.index]}"
            ]
          }
        ],
        "MaxConcurrency" : "100%",
        "MaxErrors" : "100%",
        "Accounts" : [
          {
            "Account" : "899879149844",
            "Regions" : [
              "ap-southeast-1",
              "ap-southeast-2",
              "ap-northeast-2",
              "eu-west-2",
              "sa-east-1",
              "us-east-1",
              "us-east-2",
              "us-west-2"
            ]
          },
          {
            "Account" : "383586206651",
            "Regions" : [
              "ap-southeast-1",
              "ap-southeast-2",
              "ap-northeast-2",
              "eu-west-2",
              "sa-east-1",
              "us-east-1",
              "us-east-2",
              "us-west-2"
            ]
          },
          {
            "Account" : "779537016482",
            "Regions" : [
              "us-east-1",
              "us-west-2"
            ]
          },
          {
            "Account" : "595090145094",
            "Regions" : [
              "us-east-1",
              "us-west-2"
            ]
          }
        ]
      })
    }
  }
}
