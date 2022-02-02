module UI exposing (layout)

import Css
import Css.Global
import Html
import Html.Styled as HS exposing (Html, div, text)
import Html.Styled.Attributes as Attr
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Utilities as Tw


layout : Html msg -> Html.Html msg
layout body =
    HS.toUnstyled <|
        div [ Attr.css [ Tw.bg_gray_50 ] ]
            [ Css.Global.global Tw.globalStyles
            , body
            ]
