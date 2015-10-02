/**
 * Copyright (c) 2012 committers of YAKINDU and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * Contributors:
 * 	committers of YAKINDU - initial API and implementation
 * 
 */
package Myc

import org.yakindu.sct.model.sexec.ExecutionFlow

import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.sgraph.Choice

import org.eclipse.xtext.generator.IFileSystemAccess
import com.google.inject.Inject
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EClass

class Types {

	@Inject extension Naming
	@Inject extension GenmodelEntries
	
	var String variableName

	def generateTypesH(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {		
		
		if (fsa instanceof SimpleResourceFileSystemAccess &&
			!exists(flow.testModule.h, fsa as SimpleResourceFileSystemAccess)) {
			fsa.generateFile(flow.testModule.h, flow.typesHAnnotationContent(sc,entry))
			fsa.generateFile(flow.testModule.c, flow.typesCAnnotationContent(sc,entry))
			
		}
	}

def typesCAnnotationContent(ExecutionFlow flow, Statechart sc ,GeneratorEntry entry)'''  

#import "«flow.testModule.h»"	
#pragma comment(lib, "advapi32")
			
#define HASH_INPUT "ABCDEFG123456" /* INCIDENTAL: Hardcoded crypto */
#define PAYLOAD "plaintext"
			

«FOR s: getFunctionContent(sc).entrySet»	   

// extern void «s.value» {}    

  «IF(!s.value.contains('authentication')&&(!s.value.contains('declassification'))&&(!s.value.contains('sanitization')))»           
		        void «s.value» {}
  «ENDIF»
«ENDFOR»
          
«FOR region : sc.regions»

«IF ( region.name.equalsIgnoreCase('bad_path()'))»
void «region.name»{  
	     
«FOR s: getBadPathContent(sc).entrySet» 
	«IF s.key.contains('//@ @variable')» 
	«s.key»
	«s.value»;
	«ENDIF»
	«IF s.value.contains('(')»
		«s.value»;
	«ENDIF»             
					            
		 «ENDFOR»
}	

«ENDIF»	

«IF ( region.name.equalsIgnoreCase('good_path()'))»
void «region.name»{  
«FOR s: getGoodPathContent(sc).entrySet» 
	«IF s.key.contains('//@ @variable')» 
	   «s.key»;
	«ENDIF»    
	«s.value»;  				            
«ENDFOR»
}	
«ENDIF»	
	
«ENDFOR»
          
int main(int argc, char * argv[])
{
«FOR region : sc.regions»
     «IF region.name.contains('good_path()')||region.name.contains('bad_path()') » 
	   «region.name»; 
	«ENDIF»
        
«ENDFOR»
 return 0;
}
          
'''

	def typesHAnnotationContent(ExecutionFlow flow, Statechart sc ,GeneratorEntry entry)'''  
		«FOR s: getFileContent(sc).entrySet»
		            «IF s.value.contains('(') && s.key.contains('@')» 
			            «s.key»;
			            void «s.value»;	
		            «ENDIF»          
		            
		«ENDFOR» 
	'''


	def protected exists(String filename, SimpleResourceFileSystemAccess fsa) {
		val uri = fsa.getURI(filename);
		val file = ResourcesPlugin.getWorkspace().getRoot()
					.getFile(new Path(uri.toPlatformString(true)));
		return file.exists;
	}

	
}
