ProgramNode(0...13)(
  ScopeNode(0...0)([]),
  StatementsNode(0...13)(
    [CallNode(0...13)(
       nil,
       nil,
       IDENTIFIER(0...1)("a"),
       nil,
       nil,
       nil,
       BlockNode(2...13)(
         ScopeNode(2...3)([IDENTIFIER(6...7)("b"), IDENTIFIER(9...10)("c")]),
         BlockParametersNode(5...10)(
           ParametersNode(5...10)(
             [RequiredParameterNode(9...10)()],
             [],
             RestParameterNode(5...7)(
               USTAR(5...6)("*"),
               IDENTIFIER(6...7)("b")
             ),
             [],
             nil,
             nil
           ),
           []
         ),
         nil,
         (2...3),
         (12...13)
       ),
       "a"
     )]
  )
)