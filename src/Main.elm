port module Main exposing (main)

import Browser
import Html exposing (Html, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (field, map2, string)


port makeEditor : String -> Cmd msg


port getRichText : () -> Cmd msg


port richText : (Decode.Value -> msg) -> Sub msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { text : String
    , delta : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "", makeEditor "editor" )


type Msg
    = Submit
    | GotRichText Decode.Value


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.p [ id "summary" ] [ text model.text ]
        , Html.p [ id "raw" ] [ text model.delta ]
        , Html.div [ id "editor" ] []
        , Html.button [ onClick Submit ] [ text "Submit" ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit ->
            ( model, getRichText () )

        GotRichText json ->
            let
                newModel =
                    Decode.decodeValue decoder json
                        |> Result.withDefault model
            in
            ( newModel, Cmd.none )


decoder : Decode.Decoder Model
decoder =
    map2 Model
        (field "text" string)
        (field "delta" string)


subscriptions : Model -> Sub Msg
subscriptions _ =
    richText GotRichText
