import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Styled exposing (..)

title =
  styled h2
    [ fontFamily sansSerif
    , margin (px 8)
    , fontSize (px 32)
    ]

appWrapper =
  styled div
    [ margin (px 16) ]

appBody =
  styled div
    [ margin (px 16) ]

largeInput =
  styled input
    [ fontSize (px 16) ]

largeButton =
  styled button
    [ fontSize (px 16) ]

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { username : String
  , imageUrl : String
  }

init : (Model, Cmd Msg)
init =
  ( Model "" "", Cmd.none)

type Msg = NewUsername String | GetUsername | NewImage (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg {username, imageUrl} =
  case msg of
    NewUsername user ->
      (Model user imageUrl, Cmd.none)

    GetUsername ->
      (Model username imageUrl, getGithubPicture username)

    NewImage (Ok url) ->
      (Model username url, Cmd.none)

    NewImage (Err _) ->
      (Model username imageUrl, Cmd.none)

view : Model -> Html Msg
view model =
  appWrapper []
    [ title [] [ text "Github Picture Getter" ]
    , appBody []
      [ largeInput [ placeholder "Github Username", onInput NewUsername, value model.username ] []
      , p [] []
      , largeButton [ onClick GetUsername ] [ text "Get Picture" ]
      , p [] []
      , img [ src model.imageUrl ] []
      ]
    ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

getGithubPicture : String -> Cmd Msg
getGithubPicture username =
  let
    url = "https://api.github.com/users/" ++ username
  in
    Http.send NewImage (Http.get url decodeUser)

decodeUser : Decode.Decoder String
decodeUser =
  Decode.at ["avatar_url"] Decode.string
