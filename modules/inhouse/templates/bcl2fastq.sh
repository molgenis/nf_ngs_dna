rawdata=$(basename "!{params.samplesheet}" '.csv')
rm -rf "!{params.intermediateDir}/${rawdata}"
mkdir -p -m 0775 "!{params.intermediateDir}/${rawdata}"

if dragen -f --bcl-conversion-only true --bcl-input-directory "!{params.sequencersDir}/${rawdata}/"  --output-directory "!{params.intermediateDir}/${rawdata}"  --sample-sheet "!{illuminaSamplesheet}"
then

  cp "!{params.intermediateDir}/${rawdata}/Reports/fastq_list.csv" 'fastq_list.csv'
else
  echo "Something went wrong with the execution of the bcl-conversion"
fi
mkdir -p -m 0755 "!{params.rawdataDir}/${rawdata}"
if cp -v "!{params.intermediateDir}/${rawdata}/"*".fastq.gz" "!{params.rawdataDir}/${rawdata}/"
then

	cp -v "!{params.samplesheet}" "!{params.rawdataDir}/${rawdata}/"
	
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

	if [[ -n "${sampleSheetColumnOffsets['sequencingStartDate']+isset}" ]]; then
	  sequencingStartDateFieldIndex=$((${sampleSheetColumnOffsets['sequencingStartDate']} + 1))
	fi
	if [[ -n "${sampleSheetColumnOffsets['sequencer']+isset}" ]]; then
	  sequencerFieldIndex=$((${sampleSheetColumnOffsets['sequencer']} + 1))
	fi
	if [[ -n "${sampleSheetColumnOffsets['run']+isset}" ]]; then
	  runFieldIndex=$((${sampleSheetColumnOffsets['run']} + 1))
	fi
	if [[ -n "${sampleSheetColumnOffsets['flowcell']+isset}" ]]; then
	  flowcellFieldIndex=$((${sampleSheetColumnOffsets['flowcell']} + 1))
	fi
	if [[ -n "${sampleSheetColumnOffsets['lane']+isset}" ]]; then
	  laneFieldIndex=$((${sampleSheetColumnOffsets['lane']} + 1))
	fi
	if [[ -n "${sampleSheetColumnOffsets['barcode']+isset}" ]]; then
	  barcodeFieldIndex=$((${sampleSheetColumnOffsets['barcode']} + 1))
	fi

	echo -e "${externalSampleIDFieldIndex}\t${sequencingStartDateFieldIndex}\t${sequencerFieldIndex}\t${runFieldIndex}\t${flowcellFieldIndex}\t${laneFieldIndex}\t${barcodeFieldIndex}"

	count=1
	while read line
	do
		if [[ "${count}" == 1 ]]
		then
			echo "first line"
			count=2
			continue
		fi 

		externalSampleID=$(echo "${line}" | awk -v eIndex="${externalSampleIDFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		sequencingStartDate=$(echo "${line}" | awk -v eIndex="${sequencingStartDateFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		sequencer=$(echo "${line}" | awk -v eIndex="${sequencerFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		run=$(echo "${line}" | awk -v eIndex="${runFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		flowcell=$(echo "${line}" | awk -v eIndex="${flowcellFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		lane=$(echo "${line}" | awk -v eIndex="${laneFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		barcode=$(echo "${line}" | awk -v eIndex="${barcodeFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')

	newFastQfile1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode}_1.fq.gz"
	newFastQfile2="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode}_2.fq.gz"


	echo -e "${externalSampleID}\t${sequencingStartDate}\t${sequencer}\t${run}\t${flowcell}\t${lane}\t${barcode}"	


	oldFastQfile1=$(find "!{params.rawdataDir}/${rawdata}/" -name ${externalSampleID}*L00${lane}*_R1_*)
	oldFastQfile2=$(find "!{params.rawdataDir}/${rawdata}/" -name ${externalSampleID}*L00${lane}*_R2_*) 

	mv "${oldFastQfile1}" "!{params.rawdataDir}/${rawdata}/${newFastQfile1}"
	mv "${oldFastQfile2}" "!{params.rawdataDir}/${rawdata}/${newFastQfile2}"

	done<"!{params.samplesheet}"
	
fi
