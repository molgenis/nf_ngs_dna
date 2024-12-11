#!/bin/bash

set -eu
PULLREQUEST=$1

checkout='nf_ngs_dna'
pipeline='nf_ngs_dna'

TMPDIRECTORY='/groups/umcg-gst/tmp07'
GS_RUN='105856-001'
WORKDIR="${TMPDIRECTORY}/tmp/${pipeline}/betaAutotest/"

## cleanup data to get new data
echo "cleaning up.."
rm -rvf "${TMPDIRECTORY}/${GS_RUN}/" "${TMPDIRECTORY}/Samplesheets/GS_001A-WGS_v1.csv" "${TMPDIRECTORY}/Samplesheets/NGS_DNA/GS_001-WGS_v1.csv" "${TMPDIRECTORY}/projects/NGS_DNA/GS_001-WGS_v1"

## retreive data in tmp directory
if [[ "${checkout}" == "${pipeline}" ]]
then
	echo "new pull request for nf_ngs_dna, using default NGS_Automated to get the data from the transfer server"
	rm -rf "${WORKDIR}"
	mkdir -p "${WORKDIR}"

	cd "${WORKDIR}"
	git clone "https://github.com/molgenis/${pipeline}.git"

	cd "${pipeline}" || exit
	git fetch --tags --progress "https://github.com/molgenis/${pipeline}/" +refs/pull/*:refs/remotes/origin/pr/*
	COMMIT=$(git rev-parse refs/remotes/origin/pr/${PULLREQUEST}/merge^{commit})
	echo "checkout commit: COMMIT"
	git checkout -f "${COMMIT}"

	mv * ../
	cd ..
	rm -rf "${pipeline}"
## copy samplesheet to ${TMPDIRECTORY}/Samplesheets/GS_001A-WGS_v1.csv
cp -v "${WORKDIR}/test/GS_001A-WGS_v1.csv" "${TMPDIRECTORY}/Samplesheets/"

rm -rf "${TMPDIRECTORY}/logs/${GS_RUN}/"

## get data from transfer server
var=$(crontab -l | grep PullAndProcessGsAnalysisData.sh | grep -o -P 'module(.+)')
eval ${var::-1} || {
	echo "something went wrong during the PullAndProcessGsAnalysisData step"
	exit 1
}
echo "DONE with pulling/processing, now starting the pipeline"
module load NGS_Automated
module load "${pipeline}/betaAutotest"

startNextflowDragenPipeline.sh -g umcg-gst

fi

