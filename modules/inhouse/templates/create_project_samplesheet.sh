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
if [[ -n "${sampleSheetColumnOffsets['project']+isset}" ]]; then
  projectFieldIndex=$((${sampleSheetColumnOffsets['project']} + 1))
fi

awk -v p=${projectFieldIndex} 'BEGIN {FS=","}{if (NR>1){print $p}}' "!{params.samplesheet}" > projects.txt
sort -V projects.txt | uniq > uniqprojects.csv


while read project
do
	head -1 "!{params.samplesheet}" > "${project}.csv"
	awk -v eIndex=${externalSampleIDFieldIndex} -F',' '{if (NR>1){print $eIndex}}' "!{params.samplesheet}" | sort -u > "${project}.uniquesamples"
	while read line ; do grep "${line}" "!{params.samplesheet}"| head -1 >> "${project}.csv"; done<"${project}.uniquesamples"
	
	rsync -v "${project}.csv" "!{params.tmpDataDir}/Samplesheets/POST_DRAGEN/"
done< uniqprojects.csv

touch "!{params.tmpDataDir}/logs/${rawdata}/run01.demultiplexing.finished"