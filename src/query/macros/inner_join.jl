macro inner_join(src1, src2, exprs...)
    Expr(
        :call,
        :InnerJoin,
        Expr(
            :tuple,
            analyze_src_expr(src1),
            analyze_src_expr(src2),
        ),
        Expr(
            :tuple,
            function_spec_expr.(exprs)...,
        ),
    )
end
