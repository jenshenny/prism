ProgramNode(0...39)(
  ScopeNode(0...0)([IDENTIFIER(27...29)("ex")]),
  StatementsNode(0...39)(
    [BeginNode(0...39)(
       KEYWORD_BEGIN(0...5)("begin"),
       StatementsNode(7...11)(
         [CallNode(7...11)(
            nil,
            nil,
            IDENTIFIER(7...11)("meth"),
            nil,
            nil,
            nil,
            nil,
            "meth"
          )]
       ),
       RescueNode(13...34)(
         KEYWORD_RESCUE(13...19)("rescue"),
         [CallNode(20...23)(
            nil,
            nil,
            IDENTIFIER(20...23)("foo"),
            nil,
            nil,
            nil,
            nil,
            "foo"
          )],
         EQUAL_GREATER(24...26)("=>"),
         LocalVariableWriteNode(27...29)((27...29), nil, nil),
         StatementsNode(31...34)(
           [CallNode(31...34)(
              nil,
              nil,
              IDENTIFIER(31...34)("bar"),
              nil,
              nil,
              nil,
              nil,
              "bar"
            )]
         ),
         nil
       ),
       nil,
       nil,
       KEYWORD_END(36...39)("end")
     )]
  )
)