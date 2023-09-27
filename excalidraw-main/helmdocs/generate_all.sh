#!/bin/bash
DEFAULTVALUE="default_app_name"
APPNAME="${1:-$DEFAULTVALUE}"
CURRENTDIR=$(dirname "$0")
HelmdocsConfigFile="${CURRENTDIR}/helmdocs-config.yaml"

HelmdocsValueFile=$( yq e ".helmdocs.valueFile" ${HelmdocsConfigFile} )
if [[ -z "${HelmdocsValueFile}" ]]; then
  echo "HelmdocsValueFile not SET in ${HelmdocsConfigFile} inside helmdocs.valueFile"
  exit 1
fi
HelmdocsValueFile="${CURRENTDIR}/${HelmdocsValueFile}"


HelmdocsReadmeTemplateFile=$( yq e ".helmdocs.readmeTemplateFile" ${HelmdocsConfigFile} )
if [[ -z "${HelmdocsReadmeTemplateFile}" ]]; then
  echo "HelmdocsReadmeTemplateFile not SET in ${HelmdocsConfigFile} inside helmdocs.readmeTemplateFile"
  exit 1
fi
HelmdocsReadmeTemplateFile="${CURRENTDIR}/${HelmdocsReadmeTemplateFile}"

HelmdocsTemplateFile=$( yq e ".helmdocs.templateFile" ${HelmdocsConfigFile} )
if [[ -z "${HelmdocsTemplateFile}" ]]; then
  echo "HelmdocsTemplateFile not SET in ${HelmdocsConfigFile} inside helmdocs.templateFile"
  exit 1
fi
HelmdocsTemplateFile="${CURRENTDIR}/${HelmdocsTemplateFile}"

HelmdocsIgnoreFile=$( yq e ".helmdocs.ignoreFile" ${HelmdocsConfigFile} )
if [[ -z "${HelmdocsIgnoreFile}" ]]; then
  echo "HelmdocsIgnoreFile not SET in ${HelmdocsConfigFile} inside helmdocs.ignoreFile"
  exit 1
fi
HelmdocsIgnoreFile="${CURRENTDIR}/${HelmdocsIgnoreFile}"

## Define all function

clearFile () {
  truncate -s 0 $1
}

repeatChar() {
    local input="$1"
    local count="$2"
    printf -v myString '%*s' "$count"
    printf '%s\n' "${myString// /$input}"
}


printHelmdocsValuesFile () {
  local indent=$1
  local filePath=$2
  local indentProcessed=$(repeatChar " " ${indent})
  cat "${filePath}" |sed '/# yamllint .*$/d' | sed '/^---.*$/d' | sed '/^\.\.\..*$/d' | sed "s/^/${indentProcessed}/"
  printf "\n"
}


printHelmdocsValuesKey () {
  local indent=$1
  local text=$2
  local indentProcessed=$(repeatChar " " ${indent})
  printf "${text}" | sed "s/^/${indentProcessed}/"
  printf "\n"
}


printRenderedFiles () {
  local valueKey=$1
  local
  local func_result="some result"
  echo "$func_result"
}

joinByString() {
  local separator="$1"
  shift
  local first="$1"
  shift
  printf "%s" "$first" "${@/#/$separator}"
}

processValuesBeginningFile() {
  #### First add yaml start of file
  printHelmdocsValuesKey 0 "# yamllint disable rule:line-length rule:comments-indentation\n---" >> $1
}

processValuesEndOfFile() {
  #### add yaml end of file
  printHelmdocsValuesKey 0 "\n...\n" >> $1
  #### remove trailing space
  sed -i 's/\s*$//' $1
  #### remove empty line
  sed -i '/^[[:space:]]*$/d' $1
}

processRenderedBeginningFile() {
  #### First add yaml start of file
  printHelmdocsValuesKey 0 "# yamllint disable rule:line-length rule:comments-indentation\n" >> $1
}

processRenderedEndOfFile() {
  #### remove trailing space
  sed -i 's/\s*$//' $1
  #### remove empty line
  sed -i '/^[[:space:]]*$/d' $1
}




#### Loop over parameters array in 'HelmdocsConfigFile'
#### and get values files
writeHelmdocsValuesFile () {

  local alreadyWriteKeys=()
  local indentationIndex=0
  local currentKey=""

  #### First add yaml start of file
  processValuesBeginningFile ${HelmdocsValueFile}

  readarray -t parametersNames < <(yq '.parameters |= sort_by(.name) | .parameters[].name | trim ' ${HelmdocsConfigFile} )

  for parametersName in "${parametersNames[@]}"; do
    echo "PROCESS HelmdocsValuesFile for ${parametersName}"

    ###if parametersName contains  valuesFile:
    currentValuesFile=$( yq ".parameters[] | select(.name == \"${parametersName}\") | .valuesFile" ${HelmdocsConfigFile} )
    if [[ ! -z "${currentValuesFile}" ]] && [[ "${currentValuesFile}" != "null" ]];then
      ### parametersName contains dot then it is a key path
      ### We need to split it
      if [[ ${parametersName} == *.* ]] ; then
        splitedparametersNames=(${parametersName//./ })
        for splitedparametersName in "${splitedparametersNames[@]}"; do
          currentKey+=${splitedparametersName}
          if [[ "${alreadyWriteKeys[@]/$currentKey/}" == "${alreadyWriteKeys[@]}" ]]; then
            alreadyWriteKeys+=(${currentKey})
            printHelmdocsValuesKey ${indentationIndex} "${splitedparametersName}:" >> ${HelmdocsValueFile}
          fi
          ((indentationIndex=indentationIndex+2))
        done
        currentKey=""
        printHelmdocsValuesFile ${indentationIndex} "${currentValuesFile}" >> ${HelmdocsValueFile}
        ((indentationIndex=0))
      else
        alreadyWriteKeys+=(${parametersName})
        printHelmdocsValuesKey ${indentationIndex} "${parametersName}:" >> ${HelmdocsValueFile}
        ((indentationIndex=indentationIndex+2))
        printHelmdocsValuesFile ${indentationIndex} "${currentValuesFile}" >> ${HelmdocsValueFile}
        ((indentationIndex=indentationIndex-2))
      fi
    fi
  done
  processValuesEndOfFile ${HelmdocsValueFile}
}




writeRenderedFiles() {
  ###### update helm dependencies
  echo "helm dependency update"
  helm dependency update .

  ###### First loop over keys
  local alreadyWriteKeys=()
  local indentationIndex=0

  readarray -t parametersNames < <(yq '.parameters |= sort_by(.name) | .parameters[].name | trim ' ${HelmdocsConfigFile} )

  for parametersName in "${parametersNames[@]}"; do
    echo "PROCESS RENDERED for ${parametersName}"

    ###if parametersName contains  valuesFile:
    currentValuesFile=$( yq ".parameters[] | select(.name == \"${parametersName}\") | .valuesFile" ${HelmdocsConfigFile} )
    currentRenderedFile=$( yq ".parameters[] | select(.name == \"${parametersName}\") | .rendered.file" ${HelmdocsConfigFile} )
    currentRenderedDependsOn=$( yq ".parameters[] | select(.name == \"${parametersName}\") | .rendered.dependsOn" ${HelmdocsConfigFile} )
    if [[ ! -z "${currentValuesFile}" ]] && [[ "${currentValuesFile}" != "null" ]];then
      if [[ ! -z "${currentRenderedFile}" ]] && [[ "${currentRenderedFile}" != "null" ]];then
      if [[ ! -z "${currentRenderedDependsOn}" ]] &&  [[ "${currentRenderedDependsOn}" != "null" ]]; then
        splitedDependsOn=(${currentRenderedDependsOn//,/ })
        dependsOnArray=()
        for currentSplitedDependsOn in "${splitedDependsOn[@]}"; do
          dependsOnArray+=($( yq ".parameters[] | select(.name == \"${currentSplitedDependsOn}\") | .valuesFile" ${HelmdocsConfigFile} ))
        done
        dependsOn=$(joinByString ' -f ' ${dependsOnArray[@]})
        echo "helm template . -f ${dependsOn} -f ${currentValuesFile} > ${currentRenderedFile}"
        clearFile ${currentRenderedFile}
        processRenderedBeginningFile ${currentRenderedFile}
        helm template . -f ${dependsOn} -f "${currentValuesFile}" >> ${currentRenderedFile}
        processRenderedEndOfFile ${currentRenderedFile}
      else
        echo "helm template . -f ${currentValuesFile} > ${currentRenderedFile}"
        clearFile ${currentRenderedFile}
        processRenderedBeginningFile ${currentRenderedFile}
        helm template . -f "${currentValuesFile}" >> ${currentRenderedFile}
        processRenderedEndOfFile ${currentRenderedFile}
      fi
      fi
    fi
  done
}



#### Clean helmdocs values File
echo "Clean helmdocs values File : ${HelmdocsValueFile}"
clearFile ${HelmdocsValueFile}

if [[ $( yq e ".section.valueTable.enable" ${HelmdocsConfigFile} ) == "true"  ]]; then writeHelmdocsValuesFile; fi;
if [[ $( yq e ".section.rendered.enable" ${HelmdocsConfigFile} ) == "true"  ]]; then writeRenderedFiles ; fi;

#### Run conversion helmdocs config from YAML to JSON
yq -o=json "${HelmdocsConfigFile}" > "${HelmdocsConfigFile%.yaml}.json"

helm-docs --values-file ${HelmdocsValueFile} --template-files ${HelmdocsReadmeTemplateFile} --template-files ${HelmdocsTemplateFile} --ignore-file ${HelmdocsIgnoreFile}  --chart-to-generate . --chart-search-root .
