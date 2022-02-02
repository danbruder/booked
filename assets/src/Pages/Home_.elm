module Pages.Home_ exposing (Model, Msg, page)

import Css
import Css.Global
import Effect exposing (Effect)
import Gen.Params.Home_ exposing (Params)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events as HE
import Http
import Json.Decode as JD
import Page
import Request
import Shared
import Svg.Styled as Svg exposing (svg)
import Svg.Styled.Attributes as SvgAttr
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw exposing (..)
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
    { search : String, results : List Item }


init : ( Model, Effect Msg )
init =
    ( { search = "", results = [] }, Effect.none )



-- UPDATE


type Msg
    = TypedInSearch String
    | SubmittedForm
    | GotSearchResults (Result Http.Error (List Item))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        TypedInSearch str ->
            ( { model | search = str }, Effect.none )

        SubmittedForm ->
            ( model
            , getSearchResult model.search
                |> Effect.fromCmd
            )

        GotSearchResults results ->
            case results of
                Ok items ->
                    ( { model | results = items }, Effect.none )

                Err err ->
                    ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Search Amazon"
    , body =
        [ Html.toUnstyled <|
            div [ Attr.css [ Tw.bg_gray_50 ] ]
                [ Css.Global.global Tw.globalStyles
                , div
                    [ css
                        [ max_w_3xl
                        , m_auto
                        , py_12
                        ]
                    ]
                    [ h1 [ css [ text_2xl, mb_4 ] ] [ text "Search Amazon" ]
                    , div
                        [ css [ pb_8 ] ]
                        [ viewInput model ]
                    , div []
                        [ viewItems model.results
                        ]
                    ]
                ]
        ]
    }


type alias Item =
    { title : String
    , url : String
    , imageUrl : String
    }


viewItems : List Item -> Html Msg
viewItems b =
    b
        |> List.map viewItem
        |> div
            [ css
                [ m_auto
                , w_full
                , max_w_3xl
                ]
            ]


viewItem : Item -> Html Msg
viewItem item =
    div
        [ css
            [ bg_white
            , p_4
            , mb_4
            , rounded
            , shadow
            , flex
            ]
        ]
        [ div [ css [ w_32, mr_4, flex_shrink_0 ] ]
            [ viewImg item.imageUrl
            ]
        , div
            []
            [ h2
                [ css
                    []
                ]
                [ a [ href item.url ]
                    [ text item.title
                    ]
                ]
            ]
        ]


viewImg : String -> Html Msg
viewImg url =
    img [ src url ] []


getSearchResult : String -> Cmd Msg
getSearchResult query =
    let
        decoder =
            JD.map3 Item
                (JD.field "title" JD.string)
                (JD.field "url" JD.string)
                (JD.field "image_url" JD.string)
    in
    Http.get
        { url = "/api/search?s=" ++ query
        , expect = Http.expectJson GotSearchResults (JD.list decoder)
        }


viewInput model =
    Html.form [ HE.onSubmit SubmittedForm ]
        [ div
            []
            [ div
                [ css
                    [ Tw.mt_1
                    , Tw.relative
                    , Tw.rounded_md
                    , Tw.shadow_sm
                    ]
                ]
                [ div
                    [ css
                        [ Tw.absolute
                        , Tw.inset_y_0
                        , Tw.left_0
                        , Tw.pl_3
                        , Tw.flex
                        , Tw.items_center
                        , Tw.pointer_events_none
                        ]
                    ]
                    [ svg
                        [ SvgAttr.css
                            [ Tw.h_6
                            , Tw.w_6
                            ]
                        , SvgAttr.fill "none"
                        , SvgAttr.viewBox "0 0 24 24"
                        , SvgAttr.stroke "currentColor"
                        ]
                        [ Svg.path
                            [ SvgAttr.strokeLinecap "round"
                            , SvgAttr.strokeLinejoin "round"
                            , SvgAttr.strokeWidth "2"
                            , SvgAttr.d "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                            ]
                            []
                        ]
                    ]
                , input
                    [ value model.search
                    , HE.onInput TypedInSearch
                    , css
                        [ Tw.block
                        , Tw.w_full
                        , Tw.pl_12
                        , Tw.border_gray_300
                        , Tw.rounded_md
                        , Tw.py_4
                        , Css.focus
                            [ Tw.ring_indigo_500
                            , Tw.border_indigo_500
                            ]
                        , Bp.sm
                            []
                        ]
                    , Attr.placeholder "Search..."
                    ]
                    []
                ]
            ]
        ]
