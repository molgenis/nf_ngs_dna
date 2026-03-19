#!/bin/bash

set -o pipefail
set -eu

if [[ $(hostname) == "copperfist" ]]
then
	prm='prm06'
		isilonName='leucinezipper'
 elif [[ $(hostname) == "betabarrel" ]]
 then
prm='prm05'
	isilonName='zincfinger'
elif [[ $(hostname) == "wingedhelix" ]]
then
	prm='prm07'
	isilonName='wingedhelix'
 else
	echo "unknown machine"
	exit 1
fi
	
resultsfolder="\\\\zkh\appdata\medgen\\${isilonName}\groups\umcg-gd\\${prm}\projects\\!{samples.project}\run01\results\\"
resultsfolderVariants="${resultsfolder}variants\\"
resultsfolderAlignment="${resultsfolder}alignment\\"
resultsfolderVariantsCNV="${resultsfolder}variants\cnv\\"
resultsfolderVariantsSV="${resultsfolder}variants\sv\\"
resultsfolderQC="${resultsfolder}qc\\"
resultsfolderVariantsgVCF="${resultsfolder}variants\gVCF\\"
ucscLinkdgvMerged=$(cat "/apps/data/nf_ngs_dna/default_link_to_ucsc_dgvMerged.bb")
ucscLinkunipDomain=$(cat "/apps/data/nf_ngs_dna/default_link_to_ucsc_unipDomain.bb")

	cat <<EOH > !{samples.externalSampleID}.igv.session.xml 
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<Session genome="hg38" version="8">
	<Resources>
		<Resource path="${resultsfolderVariants}!{samples.externalSampleID}.roh.bed" type="bed"/>
		<Resource path="${resultsfolderVariantsCNV}!{samples.externalSampleID}.cnv.excluded_intervals.bed.gz" type="bed"/>
		<Resource path="${resultsfolderVariantsgVCF}!{samples.externalSampleID}.hard-filtered.g.vcf.gz" type="vcf"/>
		<Resource path="${ucscLinkdgvMerged}" type="bb"/>
		<Resource path="${resultsfolderVariantsSV}!{samples.externalSampleID}.sv.vcf.gz" type="vcf"/>
		<Resource path="${resultsfolderVariantsCNV}!{samples.externalSampleID}.cnv.vcf.gz" type="vcf"/>
		<Resource path="${ucscLinkunipDomain}" type="bb"/>
		<Resource path="${resultsfolderVariants}!{samples.externalSampleID}.hard-filtered.baf.bw" type="bw"/>
		<Resource path="${resultsfolderAlignment}!{samples.externalSampleID}.bam" type="bam"/>
	</Resources>
	<Panel height="120" name="DataPanel" width="1901">
		<Track attributeKey="!{samples.externalSampleID}.hard-filtered.g.vcf.gz" clazz="org.broad.igv.variant.VariantTrack" displayMode="COLLAPSED" featureVisibilityWindow="100000" fontSize="10" groupByStrand="false" id="${resultsfolderVariantsgVCF}!{samples.externalSampleID}.hard-filtered.g.vcf.gz" name="!{samples.externalSampleID}.hard-filtered.g.vcf.gz" siteColorMode="ALLELE_FREQUENCY" visible="true"/>
		<Track attributeKey="!{samples.externalSampleID}.cnv.vcf.gz" clazz="org.broad.igv.variant.VariantTrack" displayMode="COLLAPSED" featureVisibilityWindow="100000" fontSize="10" groupByStrand="false" id="${resultsfolderVariantsCNV}!{samples.externalSampleID}.cnv.vcf.gz" name="!{samples.externalSampleID}.cnv.vcf.gz" siteColorMode="ALLELE_FREQUENCY" visible="true"/>
		<Track attributeKey="!{samples.externalSampleID}.sv.vcf.gz" clazz="org.broad.igv.variant.VariantTrack" displayMode="COLLAPSED" featureVisibilityWindow="100000" fontSize="10" groupByStrand="false" id="${resultsfolderVariantsSV}\!{samples.externalSampleID}.sv.vcf.gz" name="!{samples.externalSampleID}.sv.vcf.gz" siteColorMode="ALLELE_FREQUENCY" visible="true"/>
	</Panel>
	<Panel height="1274" name="Panel1772004925511" width="1901">
		<Track attributeKey="!{samples.externalSampleID}.bam Coverage" autoScale="true" clazz="org.broad.igv.sam.CoverageTrack" fontSize="10" id="${resultsfolderAlignment}!{samples.externalSampleID}.bam_coverage" name="!{samples.externalSampleID}.bam Coverage" snpThreshold="0.2" visible="true">
			<DataRange baseline="0.0" drawBaseline="true" flipAxis="false" maximum="84.0" minimum="0.0" type="LINEAR"/>
		</Track>
		<Track attributeKey="!{samples.externalSampleID}.bam Junctions" autoScale="false" clazz="org.broad.igv.sam.SpliceJunctionTrack" fontSize="10" groupByStrand="false" height="60" id="${resultsfolderAlignment}!{samples.externalSampleID}.bam_junctions" maxdepth="50" name="!{samples.externalSampleID}.bam Junctions" visible="false"/>
		<Track attributeKey="!{samples.externalSampleID}.bam" clazz="org.broad.igv.sam.AlignmentTrack" color="185,185,185" displayMode="EXPANDED" experimentType="OTHER" fontSize="10" id="${resultsfolderAlignment}!{samples.externalSampleID}.bam" name="!{samples.externalSampleID}.bam" visible="true">
			<RenderOptions/>
		</Track>
	</Panel>
	<Panel height="155" name="RefSeqPanel" width="1901">
		<Track attributeKey="Reference sequence" clazz="org.broad.igv.track.SequenceTrack" fontSize="10" id="Reference sequence" name="Reference sequence" sequenceTranslationStrandValue="+" shouldShowTranslation="true" visible="true"/>
		<Track attributeKey="Refseq Genes" clazz="org.broad.igv.track.FeatureTrack" colorScale="ContinuousColorScale;0.0;1037.0;255,255,255;0,0,178" fontSize="10" groupByStrand="false" id="https://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/ncbiRefSeq.txt.gz" name="Refseq Genes" visible="true"/>
		<Track attributeKey="unipDomain.bb" clazz="org.broad.igv.track.FeatureTrack" featureVisibilityWindow="395288950" fontSize="10" groupByStrand="false" id="https://hgdownload.soe.ucsc.edu/gbdb/hg38/uniprot/unipDomain.bb" name="unipDomain.bb" visible="true"/>
		<Track attributeKey="dgvMerged.bb" clazz="org.broad.igv.track.FeatureTrack" displayMode="SQUISHED" featureVisibilityWindow="37567134" fontSize="10" groupByStrand="false" id="https://hgdownload.soe.ucsc.edu/gbdb/hg38/dgv/dgvMerged.bb" name="dgvMerged.bb" visible="true"/>
	</Panel>
	<Panel height="120" name="QualityPanel" width="1901">
		<Track attributeKey="!{samples.externalSampleID}.hard-filtered.baf.bw" autoScale="false" clazz="org.broad.igv.track.DataSourceTrack" fontSize="10" id="${resultsfolderVariants}!{samples.externalSampleID}.hard-filtered.baf.bw" name="!{samples.externalSampleID}.hard-filtered.baf.bw" renderer="SCATTER_PLOT" visible="true" windowFunction="mean">
			<DataRange baseline="0.0" drawBaseline="true" flipAxis="false" maximum="1.0" minimum="0.0" type="LINEAR"/>
		</Track>
		<Track attributeKey="!{samples.externalSampleID}.roh.bed" clazz="org.broad.igv.track.FeatureTrack" colorScale="ContinuousColorScale;0.0;7.0;255,255,255;0,0,178" fontSize="10" groupByStrand="false" id="${resultsfolderVariants}!{samples.externalSampleID}.roh.bed" name="!{samples.externalSampleID}.roh.bed" visible="true"/>
		<Track attributeKey="!{samples.externalSampleID}.cnv.excluded_intervals.bed.gz" clazz="org.broad.igv.track.FeatureTrack" colorScale="ContinuousColorScale;0.0;126.0;255,255,255;0,0,178" fontSize="10" groupByStrand="false" id="${resultsfolderVariantsCNV}!{samples.externalSampleID}.cnv.excluded_intervals.bed.gz" name="!{samples.externalSampleID}.cnv.excluded_intervals.bed.gz" visible="true"/>
	</Panel>
	<PanelLayout dividerFractions="0.13819095477386933,0.6457286432160804,0.8467336683417085,0.9886934673366834"/>
	<HiddenAttributes>
		<Attribute name="DATA FILE"/>
		<Attribute name="DATA TYPE"/>
		<Attribute name="NAME"/>
	</HiddenAttributes>
</Session>
EOH

cp -v "!{samples.externalSampleID}.igv.session.xml"  "!{samples.projectResultsDir}/qc/!{samples.externalSampleID}.igv_session_versie8.xml" 