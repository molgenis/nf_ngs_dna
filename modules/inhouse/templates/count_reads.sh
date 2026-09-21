set -eu

_count_reads() {
	local    _fastq=$1
	local    _barcode=$2
	local -i _lines=$(zcat "${_fastq}" | wc -l)
	local -i _reads=$((_lines/4))
	if [ ${#_reads} -gt "${longest_read_count_length}" ]; then
		longest_read_count_length="${#_reads}"
	fi

	if [ ${#_barcode} -gt "${longest_barcode_length}" ]; then
		longest_barcode_length="${#_barcode}"
	fi
	eval "$3=${_reads}"
}

_save_log() {
	local -i _fixed_extra_line_length=13
	local -i _longest_barcode_length=$1
	local -i _longest_read_count_length=$2
	local -i _max_line_length=$((_fixed_extra_line_length+_longest_barcode_length+_longest_read_count_length))
	local    _col_header="$3"
	local    _prefix='INFO:'
	local    _sep=$(echo -n ${_prefix}; eval printf '=%.0s' {1..$_max_line_length}; echo)
	local -i _total=$4
	local    _label="$5"
	local    _log_file="$6"
	local -n _counts=$7
	
	echo "PRINTING EVERY VARIABLE:"
	echo "_fixed_extra_line_length=${_fixed_extra_line_length}"
		echo " _longest_barcode_length=$1"
		echo " _longest_read_count_length=$2"
		echo "_max_line_length=$((_fixed_extra_line_length+_longest_barcode_length+_longest_read_count_length))"
		echo "_col_header=$3"
		echo "_total=$4"
		echo "_label=$5"
		echo "log_file=$6"
		echo "_counts=(\"${!7}\")"
	
	
	
	echo "${_prefix} Demultiplex statistics for:" 
	echo "${_prefix} ${_label}" 
	echo "${_sep}" 
	printf "${_prefix} %${_longest_barcode_length}s: %${_longest_read_count_length}s      (%%)\n" 'Barcode' "${_col_header}" 
	echo "${_sep}" 
	 
	echo "${_prefix} Demultiplex statistics for:" > "${_log_file}"
	echo "${_prefix} ${_label}" >> "${_log_file}"
	echo "${_sep}" >> "${_log_file}"
	printf "${_prefix} %${_longest_barcode_length}s: %${_longest_read_count_length}s      (%%)\n" 'Barcode' "${_col_header}" >> "${_log_file}"
	echo "${_sep}" >> "${_log_file}"
	for _item in "${_counts[@]}"
	do
		local _barcode=${_item%%:*}
		local _count=${_item#*:}
		local _percentage
		_percentage=$(awk "BEGIN {printf \"%.4f\n\", (($_count/$_total)*100)}")
		printf "${_prefix} %${_longest_barcode_length}s: %${_longest_read_count_length}d  (%4.1f%%)\n" "${_barcode}" "${_count}" "${_percentage}" >> "${_log_file}"
	done
	echo "${_sep}" >> "${_log_file}"
}

rawdata=$(basename "!{params.samplesheet}" '.csv') 

rsync -v "!{params.samplesheet}" "!{params.resultsDir}/${rawdata}/"



ngsDir="!{params.rawdataDir}/${rawdata}"
cd "!{params.rawdataDir}/${rawdata}"

for i in 'Undetermined'*'.fastq.gz'
do
	if [[ "${i}" == *'L001_R1'* ]]
	then
		mv -v "${i}" "${rawdata}_L1_DISCARDED_1.fq.gz"
	elif [[ "${i}" == *'L001_R2'* ]]
	then
		mv -v "${i}" "${rawdata}_L1_DISCARDED_2.fq.gz"	
	elif [[ "${i}" == *'L002_R1'* ]]
	then
		mv -v "${i}" "${rawdata}_L2_DISCARDED_1.fq.gz"
	elif [[ "${i}" == *'L002_R2'* ]]
	then
		mv -v "${i}" "${rawdata}_L2_DISCARDED_2.fq.gz"
	elif [[ "${i}" == *'L003_R1'* ]]
	then
		mv -v "${i}" "${rawdata}_L3_DISCARDED_1.fq.gz"
	elif [[ "${i}" == *'L003_R2'* ]]
	then
		mv -v "${i}" "${rawdata}_L3_DISCARDED_2.fq.gz"

	elif [[ "${i}" == *'L004_R1'* ]]
	then
		mv -v "${i}" "${rawdata}_L4_DISCARDED_1.fq.gz"
	elif [[ "${i}" == *'L004_R2'* ]]
	then
		mv -v "${i}" "${rawdata}_L4_DISCARDED_2.fq.gz"
	fi
done
#rm -f 'Undetermined'*'.fastq.gz'
echo "start checksumming fq.gz files.."
for i in *.fq.gz
do
	if [[ ! -f "${i}.md5" ]] 
	then
#	zcat "${i}" | bgzip -@ 8 -c > ${i%.*}.tmp.gz 
#	rm -vf "${i}"
#	mv -v ${i%.*}.tmp.gz "${i}"
		md5sum "${i}" > "${i}.md5"
	fi
done
cd -


declare -i longest_read_count_length=10
declare -i longest_barcode_length=7
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

	if [[ -n "${sampleSheetColumnOffsets['barcode']+isset}" ]]
	then
	  barcodeFieldIndex=$((${sampleSheetColumnOffsets['barcode']} + 1))
	fi
	if [[ -n "${sampleSheetColumnOffsets['lane']+isset}" ]]
	then
	  laneFieldIndex=$((${sampleSheetColumnOffsets['lane']} + 1))
	fi
	
	mapfile -t barcodes < <(awk -v b=${barcodeFieldIndex} 'BEGIN {FS=","}{if (NR>1){print $b}}' "!{params.samplesheet}" | sort -V | uniq)
	mapfile -t lanes < <(awk -v l=${laneFieldIndex} 'BEGIN {FS=","}{if (NR>1){print $l}}' "!{params.samplesheet}" | sort -V | uniq)

	for lane in "${lanes[@]}"
	do
		declare -a read_pair_counts
		declare -i total_read_pairs=0
		declare label="${rawdata}_L${lane}"
		declare barcodeD="DISCARDED"
		declare fastq_1="${ngsDir}/${rawdata}_L${lane}_DISCARDED_1.fq.gz"
		declare fastq_2="${ngsDir}/${rawdata}_L${lane}_DISCARDED_2.fq.gz"
		declare -i reads_1=-1
		declare -i reads_2=-2
		echo "start counting lines in ${fastq_1}"
		_count_reads "${fastq_1}" "${barcodeD}" 'reads_1'
		echo "start counting lines in ${fastq_2}"
		_count_reads "${fastq_2}" "${barcodeD}" 'reads_2'
		if [[ "${reads_1}" != "${reads_2}" ]]
		then
			echo "FATAL: Number of reads in both ${label} FastQ files not the same!"
			exit 1
		fi
		read_pair_counts=("${barcodeD}":"${reads_1}")
		((total_read_pairs+=reads_1))

		for barcode in "${barcodes[@]}"
		do
			fastq_1="${ngsDir}/${rawdata}_L${lane}_${barcode}_1.fq.gz"
			fastq_2="${ngsDir}/${rawdata}_L${lane}_${barcode}_2.fq.gz"
			reads_1=-1
			reads_2=-2
			echo "start counting lines in ${fastq_1}"
			_count_reads "${fastq_1}" "${barcode}" 'reads_1'
			echo "start counting lines in ${fastq_2}"
			_count_reads "${fastq_2}" "${barcode}" 'reads_2'
			if [[ "${reads_1}" != "${reads_2}" ]]
			then
				echo "FATAL: Number of reads in both ${label}_${barcode} FastQ files not the same!"
				exit 1
			fi
			read_pair_counts+=("${barcode}:${reads_1}")
			((total_read_pairs+=reads_1))

		done
		echo "counting done, start writing to ${label}.demultiplexing.log files"
		declare -p read_pair_counts
		declare log="${ngsDir}/${label}.demultiplex.log"
		_save_log "${longest_barcode_length}" "${longest_read_count_length}" 'Read Pairs' "${total_read_pairs}" "${label}" "${log}" read_pair_counts
	done
	
touch "!{params.tmpDataDir}/logs/${rawdata}/run01.demultiplexing.finished"