
# For swapping staging/prod slots in an App Service

az webapp deployment slot swap  -g esferas.io -n esferas-app --slot staging --target-slot production
