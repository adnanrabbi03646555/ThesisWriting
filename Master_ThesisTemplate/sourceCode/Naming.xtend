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

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.yakindu.sct.generator.core.types.ICodegenTypeSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.Step
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.sgraph.State
import org.yakindu.sct.model.sgraph.Choice
import org.yakindu.sct.model.sexec.ExecutionChoice
import org.yakindu.sct.model.stext.naming.StextNameProvider
import org.yakindu.sct.model.stext.stext.EventDefinition
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.InternalScope
import org.yakindu.sct.model.stext.stext.OperationDefinition
import org.yakindu.sct.model.stext.stext.VariableDefinition
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sexec.TimeEvent
import java.util.List
import org.yakindu.sct.model.sgraph.Statechart
import java.util.HashMap
import org.eclipse.emf.ecore.EClass
import org.yakindu.sct.model.sexec.transformation.StatechartExtensions
import org.yakindu.sct.model.sexec.transformation.StextExtensions
import org.yakindu.sct.model.sexec.transformation.SexecExtensions
import org.yakindu.sct.model.sexec.SexecFactory
import org.yakindu.sct.model.sexec.ExecutionNode
import org.yakindu.sct.model.sgraph.Pseudostate

class Naming {
	
	@Inject extension Navigation	
	@Inject extension ICodegenTypeSystemAccess	
	@Inject private StextNameProvider provider	
	@Inject extension INamingService	
	@Inject GeneratorEntry entry	
	@Inject extension GenmodelEntries	
			
	def HashMap<String, String> getFileContent(Statechart sc) {		
		var fileContent = <String, String>newHashMap
		for( region : sc.regions){
			for(vertex : region.vertices)  {
					if (!(vertex.name.nullOrEmpty)){
						for(transition : vertex.incomingTransitions) {
							if(transition.specification.nullOrEmpty)
							  	fileContent.put(vertex.name,vertex.name)
							if((!transition.specification.contains('//@ @variable')) && !(transition.specification.nullOrEmpty))
							  	fileContent.put(transition.specification,vertex.name)					
					    }				
			        }
		    }     
	    }          
	 return fileContent
	}
	
	def HashMap<String, String> getFunctionContent(Statechart sc) {
		var functionContent = <String, String>newHashMap		
		for( region : sc.regions){        
			for(vertex : region.vertices.filter[eClass.name.contentEquals('State')])  {	 
					if ( (vertex.name.contains('(')) && (!(vertex.name.nullOrEmpty))){						
							functionContent.put(vertex.name,vertex.name)
			        }
		    }     
	    }          
	 return functionContent
	}
	def HashMap<String, String> getBadPathContent(Statechart sc) {
		var badfunctionContent = <String, String>newHashMap
		var String newName		
		for( region : sc.regions){		
			 if(region.name.equalsIgnoreCase('bad_path()')){
				for(vertex : region.vertices.filter[eClass.name.contentEquals('State')]){		
					if(!(vertex.name.contains('(')) && (!(vertex.name.nullOrEmpty))){
						for(transition : vertex.incomingTransitions) {
							badfunctionContent.put(transition.specification,vertex.name)			
					    }						    
				      }
					if((vertex.name.contains('(')) && (!(vertex.name.nullOrEmpty))){
							if ( (vertex.name.contains('char '))){
								    newName=vertex.name.replaceAll('char *','')
								    if(newName.contains('*'))	
								        newName=newName.replaceAll('\\*','')				
									badfunctionContent.put(newName,newName)
					        }
					        else
					           badfunctionContent.put(vertex.name,vertex.name)
				      }
			    }			    
			 }    
	    }          
	 return badfunctionContent
	}
	
	def String getVariableName(Statechart sc){		
		var String variablename
		for( region : sc.regions){
			for(vertex : region.vertices.filter[eClass.name.contentEquals('State')])  {	 				   
					if (!(vertex.name.contains('(')) && (!(vertex.name.nullOrEmpty))){						
							for(transition : vertex.incomingTransitions) {												
												variablename= vertex.name.replaceAll('char *','')
												if(variablename.contains('*'))
												   variablename=variablename.replaceAll('\\*','')														
					    	}
			        }
		    } 		    
		}
	return variablename
	}
	
	def HashMap<String, String> getGoodPathContent(Statechart sc) {
		var goodfunctionContent = <String, String>newHashMap		
		var String newName		  
		for( region : sc.regions){
			if(region.name.equalsIgnoreCase('good_path()')){				
                  val choiceState=0; 
                  val increment=1;                  
                 
                  for(vertex : region.vertices.filter[eClass.name.contentEquals('Choice')]){                   	
                   val sum=choiceState+increment;
                  	for(transition : vertex.incomingTransitions) {                	
                  	   System.out.println("*********"+"if\n"+sum);    
                  	}         	    
                  }                     
					for(vertex : region.vertices.filter[eClass.name.contentEquals('State')])  {				    
				            for(invertex : vertex.parentRegion.vertices.filter[eClass.name.contentEquals('State')])
				            {
				            	if(!(vertex.name.contains('(')) && (!(vertex.name.nullOrEmpty))){
										for(transition : vertex.incomingTransitions) {
												goodfunctionContent.put(transition.specification,vertex.name)					
					    				}
				            	}
								if((vertex.name.contains('(')) && (!(vertex.name.nullOrEmpty))){
																	
									if ( (vertex.name.contains('char '))){										   
										    newName=vertex.name.replaceAll('char *','')	
										    newName=newName.replaceAll('\\*','')					
											goodfunctionContent.put(newName,newName)
							        }
							        else
							           goodfunctionContent.put(vertex.name,vertex.name)
						        }				            	
				             }			             
				    } 
			}    
	    }          
	 return goodfunctionContent
	}
}