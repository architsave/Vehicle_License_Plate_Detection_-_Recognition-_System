 ind = target50main;
vec = ind2vec(ind);
 target_var = full(vec)
 %a = target_var.';
 csvwrite('C:\Users\BHARAT\Desktop\segmented\target50abinary.csv',target_var);