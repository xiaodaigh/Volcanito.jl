"""
# Description

Given an expression, `e`, convert it into an anonymous function in the form
used by broadcasting. The column names in the input table should be passes as
the second argument, `column_names`.

# Arguments

1. `e::Any`: An expression to be converted into an anonymous function
    expression.
2. `tuple_name::Any`: The local name of the tuple that the function will act
    upon. To maximize the readability of the resulting function, pass in a
    readable like `:t`. Use `safe_tuple_name` to find a name that is guaranteed
    to be safe to use.
3. `passes::NamedTuple`: A specification of which rewrite passes should be
    performed on the input. There are three that can be activated:
    1. `locals`: A pass to unescape locals as in `a + \$b`.
    2. `lift`: A pass to lift all function calls. See docs/lifting.md for more
        details.
    3. `tvl`: A pass to rewrite all uses of `||` and `&&` to use three-valued
        logic.
    Currently `lift` is disabled as the functionality is not yet complete. The
    others are enabled by default, but can be turned off for easier debugging.

# Return Values

1. `e′::Any`: A new expression that defines an anonymous function in broadcast
    form. See docs/forms.md for details.

# Examples

```
julia> broadcast_form(:(a + b), (:a, :b))
:((a, b)->begin
          #= REPL[32]:58 =#
          a + b
      end)
"""
function broadcast_form(
    @nospecialize(e::Any),
    column_names::NTuple{N, Symbol},
    passes::NamedTuple = (locals=true, lift=false, tvl=true),
) where N
    if passes.locals
        body = unescape_locals(e)
    end

    if passes.lift
        body = lift_function_calls(body)
    end

    if passes.tvl
        body = tvl(body)
    end

    :(($(column_names...),) -> $body)
end

# TODO: vector_form
# Like broadcast form, but doesn't attempt to do lifting or TVL.
