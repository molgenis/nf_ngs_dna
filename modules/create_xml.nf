process create_xml {

input: 
	tuple val(samples), path(files)

	shell:
	template 'create_xml.sh'

}
