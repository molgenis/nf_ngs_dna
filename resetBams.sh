set -eu

declare -a _sampleSheetColumnNames=()
declare -A _sampleSheetColumnOffsets=()

theNGSDNASamplesheet=$1
rm -f resetBams.sh
IFS="," read -r -a _sampleSheetColumnNames <<< "$(head -1 "${theNGSDNASamplesheet}")"

for (( _offset = 0 ; _offset < ${#_sampleSheetColumnNames[@]} ; _offset++ ))
do
	_sampleSheetColumnOffsets["${_sampleSheetColumnNames[${_offset}]}"]="${_offset}"
done

##106463-017-024-GS_394B-WGS_v1-2900350.bam


if [[ -n "${_sampleSheetColumnOffsets["project"]+isset}" ]] 
then
	projectFieldIndex=$((${_sampleSheetColumnOffsets['project']} + 1))
	
fi
if [[ -n "${_sampleSheetColumnOffsets["GS_ID"]+isset}" ]] 
then
	GSIDFieldIndex=$((${_sampleSheetColumnOffsets['GS_ID']} + 1))
fi

if [[ -n "${_sampleSheetColumnOffsets["sampleProcessStepID"]+isset}" ]] 
then
	sampleProcessStepIDFieldIndex=$((${_sampleSheetColumnOffsets['sampleProcessStepID']} + 1))
fi

if [[ -n "${_sampleSheetColumnOffsets["externalSampleID"]+isset}" ]] 
then
	externalIDFieldIndex=$((${_sampleSheetColumnOffsets['externalSampleID']} + 1))
fi
if [[ -n "${_sampleSheetColumnOffsets["gsBatch"]+isset}" ]] 
then
	gsBatchFieldIndex=$((${_sampleSheetColumnOffsets['gsBatch']} + 1))
fi
if [[ -n "${_sampleSheetColumnOffsets["originalproject"]+isset}" ]] 
then
	originalprojectFieldIndex=$((${_sampleSheetColumnOffsets['originalproject']} + 1))
fi

gsBatch=$(head -2 ${theNGSDNASamplesheet} | tail -1 | awk -v g=${gsBatchFieldIndex} 'BEGIN {FS=","}{print $g}')
projectName=$(head -2 ${theNGSDNASamplesheet} | tail -1 | awk -v g=${projectFieldIndex} 'BEGIN {FS=","}{print $g}')

echo "${projectName} AND ${gsBatch}"

tmpdirectory="/groups/umcg-genomescan/tmp06"
path="${tmpdirectory}/projects/NGS_DNA/${projectName}/run01/results/alignment/"




awk  -v tmpdir="${tmpdirectory}" -v gsBatch="${gsBatch}" -v path="$path" -v e="${externalIDFieldIndex}" -v g="${GSIDFieldIndex}" -v o="${originalprojectFieldIndex}" -v s="${sampleProcessStepIDFieldIndex}" 'BEGIN {FS=","}{if (NR>1){print "mv "path"/"$e".bam " tmpdir"/"gsBatch"/Analysis/"$g"-"$o"-"$s"/"$g"-"$o"-"$s".bam"}}' "${theNGSDNASamplesheet}" >> resetBams.sh

awk  -v tmpdir="${tmpdirectory}" -v gsBatch="${gsBatch}" -v path="$path" -v e="${externalIDFieldIndex}" -v g="${GSIDFieldIndex}" -v o="${originalprojectFieldIndex}" -v s="${sampleProcessStepIDFieldIndex}" 'BEGIN {FS=","}{if (NR>1){print "mv "path"/"$e".bam.md5sum " tmpdir"/"gsBatch"/Analysis/"$g"-"$o"-"$s"/"$g"-"$o"-"$s".bam.md5sum"}}' "${theNGSDNASamplesheet}" >> resetBams.sh

awk  -v tmpdir="${tmpdirectory}" -v gsBatch="${gsBatch}" -v path="$path" -v e="${externalIDFieldIndex}" -v g="${GSIDFieldIndex}" -v o="${originalprojectFieldIndex}" -v s="${sampleProcessStepIDFieldIndex}" 'BEGIN {FS=","}{if (NR>1){print "mv "path"/"$e".bam.md5 " tmpdir"/"gsBatch"/Analysis/"$g"-"$o"-"$s"/"$g"-"$o"-"$s".bam.md5"}}' "${theNGSDNASamplesheet}" >> resetBams.sh

awk  -v tmpdir="${tmpdirectory}" -v gsBatch="${gsBatch}" -v path="$path" -v e="${externalIDFieldIndex}" -v g="${GSIDFieldIndex}" -v o="${originalprojectFieldIndex}" -v s="${sampleProcessStepIDFieldIndex}" 'BEGIN {FS=","}{if (NR>1){print "mv "path"/"$e".bam.bai " tmpdir"/"gsBatch"/Analysis/"$g"-"$o"-"$s"/"$g"-"$o"-"$s".bam.bai"}}' "${theNGSDNASamplesheet}" >> resetBams.sh

#mv /groups/umcg-genomescan/tmp06/projects/blablabla.bam /groups/umcg-genomescan/tmp05/${gsBatch}/Analysis/ 




