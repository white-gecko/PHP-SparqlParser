/* This is a lemon grammar for the Sparql1.1 language */
%name SparqlPHPParser
%token_prefix TK_

/* as the extra argument doesn't work for the php version, You need to add this manually 
afterwards into the parser class (otherwhise we would need to use global vars):

public $main;
public $allNS = array();

function __construct ($parent) {
    $this->main = $parent;
}

function addNS($alias, $iri) {
    $this->allNS[$alias] = $iri;
}

%include { /* this will be copied blindly */

class NTToken {
	/* arrays */
	public $vars = null;
	public $bNodes = null;
	/* non-arrays */
	public $bindVar = null;
	public $query = null;
	/* booleans */
	public $hasBN = false;
	public $hasFNC = false;
	public $hasAGG = false;

	function addVars($tmpVar) {
		if (!empty($tmpVar)) {
    	    if ($this->vars == null) {
    	        $this->vars = array();
    	    }
    	    $duplicate = false;
    	    foreach ($tmpVar as $toAdd) {
    	        foreach ($this->vars as $exists) {
    	            if (strcmp($exists, $toAdd) == 0) {
    	                $duplicate = true;
    	            }
    	        }
    	        if ($duplicate == false) {
    	            $this->vars[] = $toAdd;
    	        }
    	    }
    	}
	}

	function noDuplicates($tmpVar) {
		$noDuplicate = true;
        if ($this->vars == null || $tmpVar == null) {
            return $noDuplicate;
        } else {
            foreach ($tmpVar as $toAdd) {
    	        foreach ($this->vars as $exists) {
    	            if (strcmp($exists, $toAdd) == 0) {
    	                $noDuplicate = false;
    	            }
    	        }
    	    }
        }
        return $noDuplicate;
	}

	function copyBools($tmpToken) {
		if ($this->hasBN == false) {
			$this->hasBN = $tmpToken->hasBN;
		}
		if ($this->hasFNC == false) {
			$this->hasFNC = $tmpToken->hasFNC;
		}
		if ($this->hasAGG == false) {
			$this->hasAGG = $tmpToken->hasAGG;
		}
	}
}  
}

%parse_accept {
    /*add a function to print a clean version of query (or a sparql algebra version)*/
}

%parse_failure {
    /*transfer somehow execution class and write the error into it maybe? maybe as fourth parameter (kinda wasteful as every token will throw it in the parser again)*/
}

/* this defines a symbol for the lexer */
%nonassoc PRAGMA.

start(A) ::= query(B). { A = B; }
start(B) ::= update(B). { A = B; }

query(A) ::= prologue(B) selectQuery(C) valuesClause(D). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query . PHP_EOL . D->query; }
query(A) ::= prologue(B) constructQuery(C) valuesClause(D). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query . PHP_EOL . D->query; }
query(A) ::= prologue(B) describeQuery(C) valuesClause(D). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query . PHP_EOL . D->query; }
query(A) ::= prologue(B) askQuery(C) valuesClause(D). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query . PHP_EOL . D->query; }
query(A) ::= selectQuery(B) valuesClause(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= constructQuery(B) valuesClause(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= describeQuery(B) valuesClause(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= askQuery(B) valuesClause(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= prologue(B) selectQuery(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= prologue(B) constructQuery(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= prologue(B) describeQuery(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= prologue(B) askQuery(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query; }
query(A) ::= selectQuery(B). { A = B; }
query(A) ::= constructQuery(B). { A = B; }
query(A) ::= describeQuery(B). { A = B; }
query(A) ::= askQuery(B). { A = B; }

prologue(A) ::= prefixDeclX(B) baseDecl(C) prefixDeclX(D). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query . PHP_EOL . D->query;}
prologue(A) ::= baseDecl(B) prefixDeclX(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query;}
prologue(A) ::= prefixDeclX(B) baseDecl(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query;}
prologue(A) ::= baseDecl(B). { A = new NTToken(); A->query = B->query;}
prefixDeclX(A) ::= prefixDeclX(B) prefixDecl(C). { A = new NTToken(); A->query = B->query . PHP_EOL . C->query;}
prefixDeclX(A) ::= prefixDecl(B). { A = new NTToken(); A->query = B->query;}

baseDecl(A) ::= BASE IRIREF(B) DOT. { addNS('base',B->value); A = new NTToken(); A->query = 'BASE ' . B->value . ' .';}
baseDecl(A) ::= BASE IRIREF(B). { addNS('base',B->value); A = new NTToken(); A->query = 'BASE ' . B->value;}

prefixDecl(A) ::= PREFIX PNAME_NS(B) IRIREF(C) DOT. { addNS('base',B->value); A = new NTToken(); A->query = 'PREFIX ' . B->value . C->value . ' .';}
prefixDecl(A) ::= PREFIX PNAME_NS(B) IRIREF(C). { addNS('base',B->value); A = new NTToken(); A->query = 'PREFIX ' . B->value . C->value;}

selectQuery ::= selectClause datasetClauseX whereclause solutionModifier.
selectQuery ::= selectClause datasetClauseX whereclause.
selectQuery ::= selectClause whereclause solutionModifier.
selectQuery ::= selectClause whereclause.
datasetClauseX ::= datasetClauseX datasetClause.
datasetClauseX ::= datasetClause.


subSelect ::= selectClause whereclause solutionModifier valuesClause.
subSelect ::= selectClause whereclause valuesClause.
subSelect ::= selectClause whereclause solutionModifier.
subSelect ::= selectClause whereclause.


selectClause ::= SELECT DISTINCT selectClauseX.
selectClause ::= SELECT REDUCED selectClauseX.
selectClause ::= SELECT STAR selectClauseX.
selectClause ::= SELECT DISTINCT STAR.
selectClause ::= SELECT REDUCED STAR.
selectClause ::= SELECT selectClauseX.
selectClause ::= SELECT STAR.
selectClauseX ::= selectClauseX LPARENTHESE expression AS var RPARENTHESE.
selectClauseX ::= selectClauseX LPARENTHESE expression RPARENTHESE.
selectClauseX ::= selectClauseX builtInCall.
selectClauseX ::= selectClauseX rdfLiteral.
selectClauseX ::= selectClauseX numericLiteral.
selectClauseX ::= selectClauseX booleanLiteral.
selectClauseX ::= selectClauseX var.
selectClauseX ::= selectClauseX functionCall.
selectClauseX ::= LPARENTHESE expression AS var RPARENTHESE.
selectClauseX ::= LPARENTHESE expression RPARENTHESE.
selectClauseX ::= builtInCall.
selectClauseX ::= rdfLiteral.
selectClauseX ::= numericLiteral.
selectClauseX ::= booleanLiteral.
selectClauseX ::= var.
selectClauseX ::= functionCall.

constructQuery ::= CONSTRUCT constructTemplate datasetClauseX whereclause solutionModifier.
constructQuery ::= CONSTRUCT datasetClauseX WHERE LBRACE triplesTemplate RBRACE solutionModifier.
constructQuery ::= CONSTRUCT datasetClauseX WHERE LBRACE RBRACE solutionModifier.
constructQuery ::= CONSTRUCT constructTemplate whereclause.
constructQuery ::= CONSTRUCT constructTemplate datasetClauseX whereclause.
constructQuery ::= CONSTRUCT constructTemplate whereclause solutionModifier.
constructQuery ::= CONSTRUCT WHERE LBRACE triplesTemplate RBRACE.
constructQuery ::= CONSTRUCT WHERE LBRACE RBRACE.
constructQuery ::= CONSTRUCT datasetClauseX  WHERE LBRACE triplesTemplate RBRACE.
constructQuery ::= CONSTRUCT datasetClauseX  WHERE LBRACE  RBRACE.
constructQuery ::= CONSTRUCT WHERE LBRACE triplesTemplate RBRACE solutionModifier.
constructQuery ::= CONSTRUCT WHERE LBRACE RBRACE solutionModifier.

describeQuery ::= DESCRIBE varOrIriX datasetClauseX whereclause solutionModifier.
describeQuery ::= DESCRIBE varOrIriX whereclause solutionModifier.
describeQuery ::= DESCRIBE varOrIriX datasetClauseX solutionModifier.
describeQuery ::= DESCRIBE varOrIriX datasetClauseX whereclause.
describeQuery ::= DESCRIBE varOrIriX solutionModifier.
describeQuery ::= DESCRIBE varOrIriX whereclause.
describeQuery ::= DESCRIBE varOrIriX datasetClauseX.
describeQuery ::= DESCRIBE varOrIriX.
describeQuery ::= DESCRIBE STAR datasetClauseX whereclause solutionModifier.
describeQuery ::= DESCRIBE STAR whereclause solutionModifier.
describeQuery ::= DESCRIBE STAR datasetClauseX solutionModifier.
describeQuery ::= DESCRIBE STAR datasetClauseX whereclause.
describeQuery ::= DESCRIBE STAR solutionModifier.
describeQuery ::= DESCRIBE STAR whereclause.
describeQuery ::= DESCRIBE STAR datasetClauseX.
describeQuery ::= DESCRIBE STAR.
varOrIriX ::= varOrIriX varOrIri.
varOrIriX ::= varOrIri.

askQuery ::= ASK datasetClauseX whereclause.
askQuery ::= ASK datasetClauseX whereclause solutionModifier.
askQuery ::= ASK whereclause solutionModifier.
askQuery ::= ASK whereclause.

datasetClause ::= FROM NAMED iri.
datasetClause ::= FROM iri.

whereclause ::= WHERE groupGraphPattern.
whereclause ::= groupGraphPattern.

solutionModifier ::= groupClause havingClause orderClause limitOffsetClauses.
solutionModifier ::= havingClause orderClause limitOffsetClauses.
solutionModifier ::= groupClause orderClause limitOffsetClauses.
solutionModifier ::= groupClause havingClause limitOffsetClauses.
solutionModifier ::= groupClause havingClause orderClause.
solutionModifier ::= groupClause havingClause.
solutionModifier ::= groupClause orderClause.
solutionModifier ::= groupClause limitOffsetClauses.
solutionModifier ::= orderClause limitOffsetClauses.
solutionModifier ::= havingClause limitOffsetClauses.
solutionModifier ::= havingClause orderClause.
solutionModifier ::= groupClause.
solutionModifier ::= havingClause.
solutionModifier ::= orderClause.
solutionModifier ::= limitOffsetClauses.

groupClause ::= GROUP BY groupConditionX.
groupConditionX ::= groupConditionX LPARENTHESE expression AS var RPARENTHESE.
groupConditionX ::= groupConditionX builtInCall.
groupConditionX ::= groupConditionX functionCall.
groupConditionX ::= groupConditionX LPARENTHESE expression RPARENTHESE.
groupConditionX ::= groupConditionX var.
groupConditionX ::= LPARENTHESE expression AS var RPARENTHESE.
groupConditionX ::= builtInCall.
groupConditionX ::= functionCall.
groupConditionX ::= LPARENTHESE expression RPARENTHESE.
groupConditionX ::= var.

havingClause ::= HAVING constraintX.
constraintX ::= constraintX LPARENTHESE expression RPARENTHESE.
constraintX ::= constraintX builtInCall.
constraintX ::= constraintX functionCall.
constraintX ::= LPARENTHESE expression RPARENTHESE.
constraintX ::= builtInCall.
constraintX ::= functionCall.

orderClause ::= ORDER BY orderConditionX.
orderConditionX ::= orderConditionX orderCondition.
orderConditionX ::= orderCondition.

orderCondition ::= ASC LPARENTHESE expression RPARENTHESE.
orderCondition ::= DESC LPARENTHESE expression RPARENTHESE.
orderCondition ::= LPARENTHESE expression RPARENTHESE.
orderCondition ::= builtInCall.
orderCondition ::= functionCall.
orderCondition ::= var.

limitOffsetClauses ::= limitClause offsetClause.
limitOffsetClauses ::= offsetClause limitClause.
limitOffsetClauses ::= limitClause.
limitOffsetClauses ::= offsetClause.

limitClause ::= LIMIT INTEGER.

offsetClause ::= OFFSET INTEGER.

valuesClause ::= VALUES dataBlock.

update ::= prologue update1 SEMICOLON update.
update ::= update1 SEMICOLON update.
update ::= prologue update1.
update ::= update1.

update1 ::= load.
update1 ::= clear.
update1 ::= drop.
update1 ::= add.
update1 ::= move.
update1 ::= copy.
update1 ::= create.
update1 ::= insertData.
update1 ::= deleteData.
update1 ::= deletewhere.
update1 ::= modify.

load ::= LOAD SILENT iri INTO graphRef.
load ::= LOAD iri INTO graphRef.
load ::= LOAD SILENT iri.
load ::= LOAD iri.

clear ::= CLEAR SILENT graphRefAll.
clear ::= CLEAR graphRefAll.

drop ::= DROP SILENT graphRefAll.
drop ::= DROP graphRefAll.

create ::= CREATE SILENT graphRef.
create ::= CREATE graphRef.

add ::= ADD SILENT graphOrDefault TO graphOrDefault.
add ::= ADD graphOrDefault TO graphOrDefault.

move ::= MOVE SILENT graphOrDefault TO graphOrDefault.
move ::= MOVE graphOrDefault TO graphOrDefault.

copy ::= COPY SILENT graphOrDefault TO graphOrDefault.
copy ::= COPY graphOrDefault TO graphOrDefault.

insertData ::= INSERTDATA quadData.

deleteData ::= DELETEDATA quadData.

deletewhere ::= DELETEWHERE quadPattern.

modify ::= WITH iri deleteClause insertClause usingClauseX WHERE groupGraphPattern.
modify ::= WITH iri deleteClause usingClauseX WHERE groupGraphPattern.
modify ::= WITH iri insertClause usingClauseX WHERE groupGraphPattern.
modify ::= WITH iri deleteClause insertClause WHERE groupGraphPattern.
modify ::= WITH iri deleteClause WHERE groupGraphPattern.
modify ::= WITH iri insertClause WHERE groupGraphPattern.
modify ::= deleteClause insertClause usingClauseX WHERE groupGraphPattern.
modify ::= deleteClause usingClauseX WHERE groupGraphPattern.
modify ::= insertClause usingClauseX WHERE groupGraphPattern.
modify ::= deleteClause insertClause WHERE groupGraphPattern.
modify ::= deleteClause WHERE groupGraphPattern.
modify ::= insertClause WHERE groupGraphPattern.
usingClauseX ::= usingClauseX usingClause.
usingClauseX ::= usingClause.

deleteClause ::= DELETE quadPattern.

insertClause ::= INSERT quadPattern.

usingClause ::= USING NAMED iri.
usingClause ::= USING iri.

graphOrDefault ::= GRAPH iri.
graphOrDefault ::= DEFAULT.
graphOrDefault ::= iri.

graphRef ::= GRAPH iri.

graphRefAll ::= graphRef.
graphRefAll ::= DEFAULT.
graphRefAll ::= NAMED.
graphRefAll ::= ALL.

quadPattern ::= LBRACE quads RBRACE.
quadPattern ::= LBRACE RBRACE.

quadData ::= LBRACE quads RBRACE.
quadData ::= LBRACE RBRACE.

quads ::= triplesTemplate quadsX.
quads ::= triplesTemplate.
quads ::= quadsX.
quadsX ::= quadsX quadsNotTriples DOT triplesTemplate.
quadsX ::= quadsX quadsNotTriples triplesTemplate.
quadsX ::= quadsX quadsNotTriples DOT.
quadsX ::= quadsX quadsNotTriples.
quadsX ::= quadsNotTriples DOT triplesTemplate.
quadsX ::= quadsNotTriples triplesTemplate.
quadsX ::= quadsNotTriples DOT.
quadsX ::= quadsNotTriples.

quadsNotTriples ::= GRAPH varOrIri LBRACE triplesTemplate RBRACE.
quadsNotTriples ::= GRAPH varOrIri LBRACE RBRACE.

triplesTemplate ::= triplesSameSubject DOT triplesTemplate.
triplesTemplate ::= triplesSameSubject DOT.
triplesTemplate ::= triplesSameSubject.

groupGraphPattern ::= LBRACE groupGraphPatternSub RBRACE.
groupGraphPattern ::= LBRACE subSelect RBRACE.
groupGraphPattern ::= LBRACE RBRACE.


groupGraphPatternSub(A) ::= triplesBlock(B) groupGraphPatternSubX(C). {/*check variable if GoupGraphPatternSubX has some in the array*/ A->test = B + C; }
groupGraphPatternSub ::= triplesBlock.
groupGraphPatternSub ::= groupGraphPatternSubX.
groupGraphPatternSubX ::= groupGraphPatternSubX graphPatternNotTriples DOT triplesBlock. {/*for all below set variable from graphPatternNotTriples to X and for all Tripleblock check if both have variable*/}
groupGraphPatternSubX ::= groupGraphPatternSubX graphPatternNotTriples triplesBlock.
groupGraphPatternSubX ::= groupGraphPatternSubX graphPatternNotTriples DOT.
groupGraphPatternSubX ::= groupGraphPatternSubX graphPatternNotTriples.
groupGraphPatternSubX ::= graphPatternNotTriples DOT triplesBlock.
groupGraphPatternSubX ::= graphPatternNotTriples triplesBlock.
groupGraphPatternSubX ::= graphPatternNotTriples DOT.
groupGraphPatternSubX ::= graphPatternNotTriples. 

triplesBlock ::= triplesSameSubjectPath DOT triplesBlock.
triplesBlock ::= triplesSameSubjectPath DOT.
triplesBlock ::= triplesSameSubjectPath. {/*if variable - check*/}



graphPatternNotTriples ::= groupOrUnionGraphPattern.
graphPatternNotTriples ::= optionalGraphPattern.
graphPatternNotTriples ::= minusGraphPattern.
graphPatternNotTriples ::= graphGraphPattern.
graphPatternNotTriples ::= serviceGraphPattern.
graphPatternNotTriples ::= filter.
graphPatternNotTriples ::= bind. {/*set variable*/}
graphPatternNotTriples ::= inlineData.

optionalGraphPattern ::= OPTIONAL groupGraphPattern.

graphGraphPattern ::= GRAPH varOrIri groupGraphPattern.

serviceGraphPattern ::= SERVICE SILENT varOrIri groupGraphPattern.
serviceGraphPattern ::= SERVICE varOrIri groupGraphPattern.

bind ::= BIND LPARENTHESE expression AS var RPARENTHESE.

inlineData ::= VALUES dataBlock.

dataBlock ::= inlineDataOneVar.
dataBlock ::= inlineDataFull.

inlineDataOneVar ::= var LBRACE dataBlockValueX RBRACE.
inlineDataOneVar ::= var LBRACE RBRACE.
dataBlockValueX ::= dataBlockValueX dataBlockValue. {/*count +1*/}
dataBlockValueX ::= dataBlockValue. {/*count +1*/}

inlineDataFull ::= LPARENTHESE varX RPARENTHESE LBRACE inlineDataFullX RBRACE. {/*if both >0 and equal ok, var>0 i..X =0 ok else break*/} 
inlineDataFull ::= NIL LBRACE nilX RBRACE.
inlineDataFull ::= NIL LBRACE RBRACE.
nilX ::= nilX NIL.
nilX ::= NIL.
varX ::= varX var. {/*count +1*/}
varX ::= var. {/*count +1*/}
inlineDataFullX ::= inlineDataFullX LPARENTHESE dataBlockValueX RPARENTHESE. {/*if (both >0 and equal - count = i..X.count else if unequal - break, else d..X.count)*/}
inlineDataFullX ::= inlineDataFullX NIL. {/*count = i..X.count*/}
inlineDataFullX ::= LPARENTHESE dataBlockValueX RPARENTHESE. {/*count = d..X.count*/}
inlineDataFullX ::= NIL. {/*count = 0*/}

dataBlockValue ::= iri.
dataBlockValue ::= rdfLiteral.
dataBlockValue ::= numericLiteral.
dataBlockValue ::= booleanLiteral.
dataBlockValue ::= UNDEF.

minusGraphPattern ::= SMINUS groupGraphPattern.

groupOrUnionGraphPattern ::= groupGraphPattern groupOrUnionGraphPatternX.
groupOrUnionGraphPattern ::= groupGraphPattern.
groupOrUnionGraphPatternX ::= groupOrUnionGraphPatternX UNION groupGraphPattern.
groupOrUnionGraphPatternX ::= UNION GroupGraphPattern.

filter ::= FILTER LPARENTHESE expression RPARENTHESE.
filter ::= FILTER builtInCall.
filter ::= FILTER functionCall.

functionCall ::= iri argList.

argList ::= LPARENTHESE DISTINCT expression argListX RPARENTHESE.
argList ::= LPARENTHESE expression argListX RPARENTHESE.
argList ::= NIL.
argListX ::= argListX COMMA expression.
argListX ::= COMMA expression.

expressionList ::= LPARENTHESE expression argListX RPARENTHESE.
expressionList ::= NIL.

constructTemplate ::= LBRACE constructTriples RBRACE.
constructTemplate ::= LBRACE RBRACE.

constructTriples ::= triplesSameSubject DOT constructTriples.
constructTriples ::= triplesSameSubject DOT.
constructTriples ::= triplesSameSubject.

triplesSameSubject ::= varOrTerm propertyListNotEmpty.
triplesSameSubject ::= triplesNode propertyListNotEmpty.
triplesSameSubject ::= triplesNode.

propertyListNotEmpty ::= verb objectList propertyListNotEmptyX.
propertyListNotEmpty ::= verb objectList.
propertyListNotEmptyX ::= propertyListNotEmptyX SEMICOLON verb objectList.
propertyListNotEmptyX ::= propertyListNotEmptyX SEMICOLON.
propertyListNotEmptyX ::= SEMICOLON verb objectList.
propertyListNotEmptyX ::= SEMICOLON.

verb ::= varOrIri.
verb ::= A.

objectList ::= graphNode objectListX.
objectList ::= graphNode.
objectListX ::= objectListX COMMA graphNode.
objectListX ::= COMMA graphNode.

triplesSameSubjectPath ::= varOrTerm propertyListPathNotEmpty.
triplesSameSubjectPath ::= triplesNodePath propertyListPathNotEmpty.
triplesSameSubjectPath ::= triplesNodePath.

propertyListPathNotEmpty ::= pathAlternative objectListPath propertyListPathNotEmptyX.
propertyListPathNotEmpty ::= var objectListPath propertyListPathNotEmptyX.
propertyListPathNotEmpty ::= pathAlternative objectListPath.
propertyListPathNotEmpty ::= var objectListPath.
propertyListPathNotEmptyX ::= propertyListPathNotEmptyX SEMICOLON pathAlternative objectList.
propertyListPathNotEmptyX ::= propertyListPathNotEmptyX SEMICOLON var objectList.
propertyListPathNotEmptyX ::= propertyListPathNotEmptyX SEMICOLON.
propertyListPathNotEmptyX ::= SEMICOLON pathAlternative objectList.
propertyListPathNotEmptyX ::= SEMICOLON var objectList.
propertyListPathNotEmptyX ::= SEMICOLON.

objectListPath ::= objectPath objectListPathX.
objectListPath ::= objectPath.
objectListPathX ::= objectListPathX COMMA objectPath.
objectListPathX ::= COMMA objectPath.

pathAlternative ::= pathSequence pathAlternativeX.
pathAlternative ::= pathSequence.
pathAlternativeX ::= pathAlternativeX VBAR pathSequence.
pathAlternativeX ::= VBAR pathSequence.

pathSequence ::= pathEltOrInverse pathSequenceX.
pathSequence ::= pathEltOrInverse.
pathSequenceX ::= pathSequenceX SLASH pathEltOrInverse.
pathSequenceX ::= SLASH pathEltOrInverse.

pathElt ::= pathPrimary pathMod.
pathElt ::= pathPrimary.

pathEltOrInverse ::= HAT pathElt.
pathEltOrInverse ::= pathElt.

pathMod ::= STAR.
pathMod ::= PLUS.
pathMod ::= QUESTION.

pathPrimary ::= LPARENTHESE pathAlternative RPARENTHESE.
pathPrimary ::= EXCLAMATION pathNegatedPropertySet.
pathPrimary ::= A.
pathPrimary ::= iri.

pathNegatedPropertySet ::= LPARENTHESE pathOneInPropertySet pathNegatedPropertySetX RPARENTHESE.
pathNegatedPropertySet ::= LPARENTHESE pathOneInPropertySet RPARENTHESE.
pathNegatedPropertySet ::= LPARENTHESE RPARENTHESE.
pathNegatedPropertySet ::= pathOneInPropertySet.
pathNegatedPropertySetX ::= pathNegatedPropertySetX VBAR pathOneInPropertySet.
pathNegatedPropertySetX ::= VBAR pathOneInPropertySet.

pathOneInPropertySet ::= HAT iri.
pathOneInPropertySet ::= HAT A.
pathOneInPropertySet ::= A.
pathOneInPropertySet ::= iri.

triplesNode ::= collection.
triplesNode ::= blankNodePropertyList.

blankNodePropertyList ::= LBRACKET propertyListNotEmpty RBRACKET.

triplesNodePath ::= collectionPath.
triplesNodePath ::= blankNodePropertyListPath.

blankNodePropertyListPath ::= LBRACKET propertyListPathNotEmpty RBRACKET.

collection ::= LPARENTHESE graphNodeX RPARENTHESE.
graphNodeX ::= graphNodeX graphNode.
graphNodeX ::= graphNode.

collectionPath ::= LPARENTHESE graphNodePathX RPARENTHESE.
graphNodePathX ::= graphNodePathX graphNodePath.
graphNodePathX ::= graphNodePath.

graphNode ::= varOrTerm.
graphNode ::= triplesNode.

graphNodePath ::= varOrTerm.
graphNodePath ::= triplesNodePath.

varOrTerm ::= var.
varOrTerm ::= graphTerm.

varOrIri ::= var.
varOrIri ::= iri.

var ::= VAR1.
var ::= VAR2.

graphTerm ::= iri.
graphTerm ::= rdfLiteral.
graphTerm ::= numericLiteral.
graphTerm ::= booleanLiteral.
graphTerm ::= blankNode.
graphTerm ::= NIL.

expression ::= conditionalOrExpression.

conditionalOrExpression ::= conditionalAndExpression conditionalOrExpressionX.
conditionalOrExpression ::= conditionalAndExpression.
conditionalOrExpressionX ::= conditionalOrExpressionX OR conditionalAndExpression.
conditionalOrExpressionX ::= OR conditionalAndExpression.

conditionalAndExpression ::= valueLogical conditionalAndExpressionX.
conditionalAndExpression ::= valueLogical.
conditionalAndExpressionX ::= conditionalAndExpressionX AND valueLogical.
conditionalAndExpressionX ::= AND valueLogical.

valueLogical ::= relationalExpression.

relationalExpression ::= additiveExpression relationalExpressionX.
relationalExpression ::= additiveExpression.
relationalExpressionX ::= EQUAL additiveExpression.
relationalExpressionX ::= NEQUAL additiveExpression.
relationalExpressionX ::= SMALLERTHEN additiveExpression.
relationalExpressionX ::= GREATERTHEN additiveExpression.
relationalExpressionX ::= SMALLERTHENQ additiveExpression.
relationalExpressionX ::= GREATERTHENQ additiveExpression.
relationalExpressionX ::= IN expressionList.
relationalExpressionX ::= NOT IN expressionList.

additiveExpression ::= multiplicativeExpression additiveExpressionX.
additiveExpression ::= multiplicativeExpression.
additiveExpressionX ::= additiveExpressionX numericLiteralPositive additiveExpressionY.
additiveExpressionX ::= additiveExpressionX numericLiteralNegative additiveExpressionY.
additiveExpressionX ::= additiveExpressionX numericLiteralPositive.
additiveExpressionX ::= additiveExpressionX numericLiteralNegative.
additiveExpressionX ::= additiveExpressionX PLUS multiplicativeExpression.
additiveExpressionX ::= additiveExpressionX MINUS multiplicativeExpression.
additiveExpressionX ::= numericLiteralPositive additiveExpressionY.
additiveExpressionX ::= numericLiteralNegative additiveExpressionY.
additiveExpressionX ::= numericLiteralPositive.
additiveExpressionX ::= numericLiteralNegative.
additiveExpressionX ::= PLUS multiplicativeExpression.
additiveExpressionX ::= MINUS multiplicativeExpression.
additiveExpressionY ::= additiveExpressionY STAR unaryExpression.
additiveExpressionY ::= additiveExpressionY SLASH unaryExpression.
additiveExpressionY ::= STAR unaryExpression.
additiveExpressionY ::= SLASH unaryExpression.

multiplicativeExpression ::= unaryExpression additiveExpressionY.
multiplicativeExpression ::= unaryExpression.

unaryExpression ::= EXCLAMATION primaryExpression.
unaryExpression ::= PLUS primaryExpression.
unaryExpression ::= MINUS primaryExpression.
unaryExpression ::= primaryExpression.

primaryExpression ::= LPARENTHESE expression RPARENTHESE.
primaryExpression ::= builtInCall.
primaryExpression ::= iri.
primaryExpression ::= functionCall.
primaryExpression ::= rdfLiteral.
primaryExpression ::= numericLiteral.
primaryExpression ::= booleanLiteral.
primaryExpression ::= var.

builtInCall ::= aggregate.
builtInCall ::= regexExpression.
builtInCall ::= existsFunc.
builtInCall ::= notExistsFunc.
builtInCall ::= STR LPARENTHESE expression RPARENTHESE.
builtInCall ::= LANG LPARENTHESE expression RPARENTHESE.
builtInCall ::= LANGMATCHES LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= DATATYPE LPARENTHESE expression RPARENTHESE.
builtInCall ::= BOUND LPARENTHESE var RPARENTHESE.
builtInCall ::= URI LPARENTHESE expression RPARENTHESE.
builtInCall ::= BNODE LPARENTHESE expression RPARENTHESE.
builtInCall ::= BNODE NIL.
builtInCall ::= RAND NIL.
builtInCall ::= ABS LPARENTHESE expression RPARENTHESE.
builtInCall ::= CEIL LPARENTHESE expression RPARENTHESE.
builtInCall ::= FOOR LPARENTHESE expression RPARENTHESE.
builtInCall ::= ROUND LPARENTHESE expression RPARENTHESE.
builtInCall ::= CONCAT expressionList.
builtInCall ::= subStringExpression.
builtInCall ::= STRLEN LPARENTHESE expression RPARENTHESE.
builtInCall ::= strReplaceExpression.
builtInCall ::= UCASE LPARENTHESE expression RPARENTHESE.
builtInCall ::= LCASE LPARENTHESE expression RPARENTHESE.
builtInCall ::= ENCODE_FOR_URI LPARENTHESE expression RPARENTHESE.
builtInCall ::= CONTAINS LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= STRSTARTS LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= STRENDS LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= STBEFORE LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= STRAFTER LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= YEAR LPARENTHESE expression RPARENTHESE.
builtInCall ::= MONTH LPARENTHESE expression RPARENTHESE.
builtInCall ::= DAY LPARENTHESE expression RPARENTHESE.
builtInCall ::= HOURS LPARENTHESE expression RPARENTHESE.
builtInCall ::= MINUTES LPARENTHESE expression RPARENTHESE.
builtInCall ::= SECONDS LPARENTHESE expression RPARENTHESE.
builtInCall ::= TIMEZONE LPARENTHESE expression RPARENTHESE.
builtInCall ::= TZ LPARENTHESE expression RPARENTHESE.
builtInCall ::= NOW NIL.
builtInCall ::= UUID NIL.
builtInCall ::= STRUUID NIL.
builtInCall ::= MD5 LPARENTHESE expression RPARENTHESE.
builtInCall ::= SHA1 LPARENTHESE expression RPARENTHESE.
builtInCall ::= SHA256 LPARENTHESE expression RPARENTHESE.
builtInCall ::= SHA384 LPARENTHESE expression RPARENTHESE.
builtInCall ::= SHA512 LPARENTHESE expression RPARENTHESE.
builtInCall ::= COALESCE expressionList.
builtInCall ::= IF LPARENTHESE expression COMMA expression COMMA expression RPARENTHESE.
builtInCall ::= STRLANG LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= STRDT LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= SAMETERM LPARENTHESE expression COMMA expression RPARENTHESE.
builtInCall ::= ISIRI LPARENTHESE expression RPARENTHESE.
builtInCall ::= ISURI LPARENTHESE expression RPARENTHESE.
builtInCall ::= ISBLANK LPARENTHESE expression RPARENTHESE.
builtInCall ::= ISLITERAL LPARENTHESE expression RPARENTHESE.
builtInCall ::= ISNUMERIC LPARENTHESE expression RPARENTHESE.

regexExpression ::= REGEX LPARENTHESE expression COMMA expression COMMA expression RPARENTHESE.
regexExpression ::= REGEX LPARENTHESE expression COMMA expression RPARENTHESE.

subStringExpression ::= SUBSTR LPARENTHESE expression COMMA expression COMMA expression RPARENTHESE.
subStringExpression ::= SUBSTR LPARENTHESE expression COMMA expression RPARENTHESE.

strReplaceExpression ::= REPLACE LPARENTHESE expression COMMA expression COMMA expression COMMA expression RPARENTHESE.
strReplaceExpression ::= REPLACE LPARENTHESE expression COMMA expression COMMA expression RPARENTHESE.

existsFunc ::= EXISTS groupGraphPattern.

notExistsFunc ::= NOT EXISTS groupGraphPattern.

aggregate ::= COUNT LPARENTHESE DISTINCT STAR RPARENTHESE.
aggregate ::= COUNT LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= COUNT LPARENTHESE STAR RPARENTHESE.
aggregate ::= COUNT LPARENTHESE expression RPARENTHESE.
aggregate ::= SUM LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= MIN LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= MAX LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= AVG LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= SAMPLE LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= SUM LPARENTHESE expression RPARENTHESE.
aggregate ::= MIN LPARENTHESE expression RPARENTHESE.
aggregate ::= MAX LPARENTHESE expression RPARENTHESE.
aggregate ::= AVG LPARENTHESE expression RPARENTHESE.
aggregate ::= SAMPLE LPARENTHESE expression RPARENTHESE.
aggregate ::= GROUP_CONCAT LPARENTHESE DISTINCT expression SEMICOLON SEPARATOR EQUAL string RPARENTHESE.
aggregate ::= GROUP_CONCAT LPARENTHESE DISTINCT expression RPARENTHESE.
aggregate ::= GROUP_CONCAT LPARENTHESE expression SEMICOLON SEPARATOR EQUAL string RPARENTHESE.
aggregate ::= GROUP_CONCAT LPARENTHESE expression RPARENTHESE.

rdfLiteral ::= string LANGTAG.
rdfLiteral ::= string DHAT iri.
rdfLiteral ::= string.

numericLiteral ::= numericLiteralUnsigned.
numericLiteral ::= numericLiteralPositive.
numericLiteral ::= numericLiteralNegative.

numericLiteralUnsigned ::= INTEGER.
numericLiteralUnsigned ::= DECIMAL.
numericLiteralUnsigned ::= DOUBLE.

numericLiteralPositive ::= INTEGER_POSITIVE.
numericLiteralPositive ::= DECIMAL_POSITIVE.
numericLiteralPositive ::= DOUBLE_POSITIVE.

numericLiteralNegative ::= INTEGER_NEGATIVE.
numericLiteralNegative ::= DECIMAL_NEGATIVE.
numericLiteralNegative ::= DOUBLE_NEGATIVE.

booleanLiteral ::= TRUE.
booleanLiteral ::= FALSE.

string ::= STRING_LITERAL1.
string ::= STRING_LITERAL2.
string ::= STRING_LITERAL_LONG1.
string ::= STRING_LITERAL_LONG2.

iri ::= IRIREF.
iri ::= prefixedName.

prefixedName ::= PNAME_LN.
prefixedName ::= PNAME_NS.

blankNode(A) ::= BLANK_NODE_LABEL(B). {A = new NTToken(); A->hasBN = true; A->bNodes[] = B->value;}
blankNode(A) ::= ANON. {A = new NTToken(); A->hasBN = true;}

/* solved issues: * + through loops, update is allowed to be empty (completely empty) -> removed, 
 * no vars in quadData -> extra rules, no blanknodes in delete where, delete clause, 
 * delete data -> extra rules,
 * troublemaker: DataBlock - needs same amount of variables and datablockvalues, scoping, 
 * limiting aggregates, custom aggregates
 * idea for variables - store them in a array and shove them up (if you need to) --- check variable arrays where you need to for scoping 
*/
