import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode

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
  div []
    [ input [onInput NewUsername, value model.username] []
    , button [onClick GetUsername] [text "Get Picture"]
    , br [] []
    , img [src model.imageUrl] []
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
