module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Gen.Params.Home_ exposing (Params)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Page
import Request
import Shared
import Tailwind.Utilities as Tw exposing (..)
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : ( Model, Effect Msg )
init =
    ( {}, Effect.none )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "hey"
    , body =
        [ UI.layout <| viewBooks (List.reverse books)
        ]
    }


books =
    [ Book "Parenting" "Paul Tripp" "parenting.webp"
    , Book "Finding the Right Hills to Die On: The Case for Theological Triage" "Gavin Ortlund" "finding.webp"
    , Book "Daring Greatly" "Brene Brown" "daring.webp"
    , Book "On Birth" "Tim Keller" "onbirth.jpeg"
    , Book "On Marriage " "Tim Keller" "onmarriage.jpeg"
    , Book "On Death " "Tim Keller" "ondeath.jpeg"
    , Book "The One Thing " "Gary Keller" "onething.jpg"
    , Book "Future Men: Raising Boys to Fight Giants " "Douglas Wilson" "futuremen.webp"
    , Book "The Four Seasons of Marriage " "Douglas Wilson" "fourseasons.webp"
    , Book "Standing in the Fire " "Tom Doyle" "standing.webp"
    , Book "Be a Circle Maker" "Mark Batterson" "circle.webp"
    , Book "Atomic Habits" "James Clear" "atomic.webp"
    ]


type alias Book =
    { title : String
    , author : String
    , url : String
    }


viewBooks : List Book -> Html Msg
viewBooks b =
    b
        |> List.map viewBook
        |> div
            [ css
                [ m_auto
                , w_full
                , max_w_xl
                ]
            ]


viewBook : Book -> Html Msg
viewBook book =
    div
        [ css
            [ bg_white
            , p_4
            , rounded
            , shadow
            , flex
            ]
        ]
        [ div [ css [ w_32, mr_4, flex_shrink_0 ] ]
            [ viewImg book.url
            ]
        , div
            []
            [ h2
                [ css
                    [ font_bold
                    , text_xl
                    ]
                ]
                [ text book.title ]
            , p
                [ css
                    [ text_gray_500
                    , uppercase
                    ]
                ]
                [ text book.author ]
            ]
        ]


viewImg : String -> Html Msg
viewImg url =
    img [ src ("/img/" ++ url) ] []
