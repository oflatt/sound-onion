module DrawProgram exposing (drawProgram)
import DrawFunc exposing (drawFuncWithConnections)
import DrawToolbar
import Model exposing (..)
import ModelHelpers
import ViewStructure exposing (mouseToSvgCoordinates, ViewStructure)
import ViewPositions exposing (getViewStructures)
import ViewVariables
import SvgDraw
import Update exposing (nodeInputId, nodeOutputId)


import Browser

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src, rel)
import Html.Styled.Events exposing (onClick, onMouseOver, onMouseLeave)

import Dict exposing (Dict)
import Array exposing (Array)


import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events


import Html.Events exposing (onInput)

import Debug exposing (log)


maxYOfStructures positioned =
    (Maybe.withDefault 0 (List.maximum (List.map (\structure -> structure.headerPos.ypos + structure.funcHeight) positioned)))

                               
-- function for drawing the onion
drawOnion: Onion -> MouseState -> Int -> Int -> (Int, List (Svg Msg)) -- funcs and max height
drawOnion onion mouseState svgWindowWidth svgWindowHeight =
    let viewStructures = getViewStructures onion mouseState svgWindowWidth svgWindowHeight
    in
        ((maxYOfStructures viewStructures)
        ,(List.map drawFuncWithConnections viewStructures))
            


                     
drawProgram : Onion -> MouseState -> Int -> Int -> Html Msg
drawProgram program mouseState svgWindowWidth svgWindowHeight =
    let viewportWidth = (ViewVariables.viewportWidth svgWindowWidth svgWindowHeight)
        viewportHeight = (ViewVariables.viewportHeight)
        drawnOnion = (drawOnion program mouseState svgWindowWidth svgWindowHeight)
        drawnToolbar = (DrawToolbar.drawToolbar program mouseState svgWindowWidth svgWindowHeight)
        actualViewportHeight = Basics.max (Tuple.first drawnOnion) (Tuple.first drawnToolbar)
        actualWindowHeight = floor ((toFloat svgWindowHeight) * ((toFloat actualViewportHeight) / (toFloat viewportHeight)))
    in
        fromUnstyled
        (Svg.svg
             ((SvgDraw.svgClickEvents NoOp NoOp)
                  ++
                  [ Svg.Attributes.width(String.fromInt svgWindowWidth) -- define the width of the svg
                  , Svg.Attributes.height(String.fromInt actualWindowHeight) -- define the height of the svg
                  , Svg.Attributes.viewBox("0 0 " ++ (String.fromInt viewportWidth)
                                               ++ " " ++ (String.fromInt actualViewportHeight))
                  , display "inline-block"
                  ])
             ((Tuple.second drawnToolbar) ::
                  (Tuple.second drawnOnion)))
