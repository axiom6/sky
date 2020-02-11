@xdays = {
  x170709:{ r1:{ status:"book", resId:1707091 } },
  x170710:{ r1:{ status:"book", resId:1707091 }, r2:{ status:"depo", resId:1707102 } },
  x170711:{ r2:{ status:"depo", resId:1707102 }, r3:{ status:"book", resId:1707113 } },
  x170712:{ r3:{ status:"book", resId:1707113 }, r4:{ status:"book", resId:1707124 } },
  x170713:{ r4:{ status:"book", resId:1707124 } },
  x170714:{ r5:{ status:"depo", resId:1707145 } },
  x170715:{ r5:{ status:"depo", resId:1707145 }, r6:{ status:"book", resId:1707156 } },
  x170716:{ r6:{ status:"book", resId:1707156 }, r7:{ status:"book", resId:1707167 } },
  x170717:{ r7:{ status:"book", resId:1707167 }, r8:{ status:"book", resId:1707178 } },
  x170718:{ r8:{ status:"book", resId:1707178 }, rN:{ status:"book", resId:1707189 } },
  x170719:{ rN:{ status:"book", resId:1707189 }, rS:{ status:"book", resId:1707190 } },
  x170720:{ rS:{ status:"book", resId:1707190 } } }

makeAllTables:() ->
  @store.make( 'Res'     )
  @store.make( 'Room'    )
  @store.make( 'Days'    )
  @store.make( 'Payment' )
  @store.make( 'Cust'    )