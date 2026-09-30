set -eu

rawdata=$(basename "!{params.samplesheet}" '.csv') 

rsync -v "!{params.samplesheet}" "!{params.resultsDir}/${rawdata}/"

ngsDir="!{params.rawdataDir}/${rawdata}"
echo "creating ${ngsDir}/Info/"
mkdir -p "${ngsDir}/Info/"
nextSeqRunDataDir="!{params.sequencersDir}/${rawdata}/"
Q30=$(summary "${nextSeqRunDataDir}" | grep Total | awk 'BEGIN{FS=","}{print $7}')
echo "Q30:${Q30}"
if [[ -f "${nextSeqRunDataDir}/RunCompletionStatus.xml" ]]
then
	ClusterDensity=$(grep ClusterDensity "${nextSeqRunDataDir}/RunCompletionStatus.xml" | grep -Eo '[0-9]{1,9}[.][0-9]{1,9}')
	echo "ClusterDensity:${ClusterDensity}"
	ClustersPassingfilter=$(grep ClustersPassingFilter "${nextSeqRunDataDir}/RunCompletionStatus.xml" | grep -Eo '[0-9]{1,9}[.][0-9]{1,9}')
	echo "ClustersPassingfilter:${ClustersPassingfilter}"
	rsync -v "${nextSeqRunDataDir}/RunCompletionStatus.xml" "${ngsDir}/Info/"
else
	ClusterDensity=""
	ClustersPassingfilter=""
fi
year=$(summary "${nextSeqRunDataDir}" | head -9 | sed 's/ //g' | grep -Eo '[1-4]{1}[0-9]{5}'| cut -b 1,2)
month=$(summary "${nextSeqRunDataDir}" | head -9 | sed 's/ //g' | grep -Eo '[1-4]{1}[0-9]{5}' | cut -b 3,4)
day=$(summary "${nextSeqRunDataDir}" | head -9 | sed 's/ //g' | grep -Eo '[1-4]{1}[0-9]{5}' | cut -b 5,6)

echo "date:${day}/${month}/${year}"

sequencingDate="${day}/${month}/20${year}"
echo "sequencingDate:${sequencingDate}"

echo -e "Sample,Run,Date\n${rawdata},run01,${sequencingDate}" > "${ngsDir}/Info/SequenceRun_run_date_info.csv"
echo -e "Sample\tClusterDensity(K/mm2)\tClustersPassingFilter(%)\tPercentage>=Q30\n${rawdata}\t${ClusterDensity}\t${ClustersPassingfilter}\t${Q30}" > "${ngsDir}/Info/SequenceRun.csv"


#deze zouden waarschijnlijk niet eens mee hoeven.
rsync -rv "${nextSeqRunDataDir}/InterOp" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/RunInfo.xml" "${ngsDir}/Info/"
rsync -v "${nextSeqRunDataDir}/"*"unParameters.xml" "${ngsDir}/Info/"



