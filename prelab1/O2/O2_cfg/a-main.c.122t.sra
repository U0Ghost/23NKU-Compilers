
;; Function main (main, funcdef_no=23, decl_uid=2545, cgraph_uid=24, symbol_order=23) (executed once)

int main ()
{
  int f;
  int n;
  int i;
  int n.0_1;
  int n.0_12;

  <bb 2> [local count: 118111600]:
  scanf ("%d", &n);
  n.0_12 = n;
  if (n.0_12 > 1)
    goto <bb 3>; [89.00%]
  else
    goto <bb 4>; [11.00%]

  <bb 3> [local count: 955630225]:
  # i_13 = PHI <i_9(3), 2(2)>
  # f_14 = PHI <f_8(3), 1(2)>
  f_8 = f_14 * i_13;
  i_9 = i_13 + 1;
  n.0_1 = n;
  if (n.0_1 >= i_9)
    goto <bb 3>; [89.00%]
  else
    goto <bb 4>; [11.00%]

  <bb 4> [local count: 118111600]:
  # f_15 = PHI <f_8(3), 1(2)>
  __printf_chk (1, "%d", f_15);
  n ={v} {CLOBBER};
  return 0;

}


