module Compiler.CompileBuiltIn exposing (buildWave, buildUnary, buildJavascriptCall, buildUnaryWithDefault, buildUnaryWithSingleLead)
    
import Compiler.CompModel exposing (Expr, Method, CompModel, Value(..), AST(..))
import Compiler.CompileToAST exposing (getCacheValue)


buildValue val =
    case val of
        StackIndex i ->
            getCacheValue (Literal (String.fromInt i))
        ConstV c ->
            Literal (String.fromFloat c)
                
buildWave : Expr -> AST
buildWave expr =
    case expr.children of
        (time::frequency::duration::[]) ->
            let timeAST = buildValue time
                frequencyAST = buildValue frequency
                durationAST = buildValue duration
            in
                (Begin
                     [(If (Unary "&&"
                               (Unary ">=" (Literal "time") timeAST)
                               (Unary "<" (Literal "time") (Unary "+" timeAST durationAST)))
                          (NotesPush frequencyAST)
                          Empty)
                     ,(Unary "+" timeAST durationAST)])
        _ -> Empty -- fail silently


             
buildUnaryMultiple children op =
    case children of
        [] -> Empty -- should not happen
        (arg::[]) -> (buildValue arg)-- should not happen
        (arg::args) -> (Unary op (buildValue arg) (buildUnaryMultiple args op))

buildGeneralUnary defaultValue singleArgumentLead expr =
    (case expr.children of
         [] -> (Literal defaultValue)
         (arg::[]) ->
             case singleArgumentLead of
                 "" -> (buildValue arg)
                 lead -> SingleOp lead (buildValue arg)
         _ -> (buildUnaryMultiple expr.children expr.functionName))

             
buildUnary expr =
    buildGeneralUnary "0" "" expr
                                          
buildUnaryWithDefault default expr =
    buildGeneralUnary default "" expr

buildUnaryWithSingleLead lead expr =
    buildGeneralUnary "0" lead expr

buildJavascriptCall funcName expr =
    CallFunction (Literal funcName) (List.map buildValue expr.children)
                                          
