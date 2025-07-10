rawdata=$(basename "!{params.samplesheet}" '.csv') 

rsync -v "!{params.samplesheet}" "!{params.resultsDir}/${rawdata}/"
touch stats.tsv
cp stats.tsv "!{params.resultsDir}/${rawdata}/Analysis/"

declare -a sampleSheetColumnNames=()
declare -A sampleSheetColumnOffsets=()
declare    sampleSheetFieldIndex
declare    sampleSheetFieldValueCount

IFS="," read -r -a sampleSheetColumnNames <<< "$(head -1 !{params.samplesheet})"
for (( offset = 0 ; offset < ${#sampleSheetColumnNames[@]} ; offset++ ))
do
	columnName="${sampleSheetColumnNames[${offset}]}"
	sampleSheetColumnOffsets["${columnName}"]="${offset}"

done

if [[ -n "${sampleSheetColumnOffsets['externalSampleID']+isset}" ]]; then
  externalSampleIDFieldIndex=$((${sampleSheetColumnOffsets['externalSampleID']} + 1))
fi

head -1 "!{params.samplesheet}" > "!{samples.project[0]}.csv"
awk -v eIndex=${externalSampleIDFieldIndex} -F',' '{if (NR>1){print $eIndex}}' "!{params.samplesheet}" | sort -u > "!{samples.project[0]}}.csv.tmp"

while read line ; do grep "${line}" "!{params.samplesheet}"| head -1 >> "!{samples.project[0]}.csv"; done<"!{samples.project[0]}.csv.tmp"

rsync -v "!{samples.project[0]}.csv" "!{params.tmpDataDir}/Samplesheets/POST_DRAGEN/"