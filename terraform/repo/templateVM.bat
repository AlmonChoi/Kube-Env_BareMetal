echo off
set workingDir=newVM
set varFile=templateVM.tfvars

If "%1"=="" goto plan
If "%1"=="plan" goto plan
If "%1"=="init" goto init
If "%1"=="apply" goto apply
If "%1"=="fmt" goto fmt
If "%1"=="validate" goto validate


:init
echo on
terraform -chdir=%workingDir% init
echo off
goto end

:fmt
echo on
terraform -chdir=%workingDir% fmt
echo off
goto end

:validate
echo on
terraform -chdir=%workingDir% validate
echo off
goto end


:apply
echo on
terraform -chdir=%workingDir% apply -state=..\tfstate\terraform.tfstate -var-file="%varFile%"
echo off
goto end

:plan
echo on
terraform -chdir=%workingDir% plan -state=..\tfstate\terraform.tfstate -var-file="%varFile%"
echo off
goto end

:end
