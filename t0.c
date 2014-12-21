
#include <stdio.h>

int memInitialize(unsigned int);
void *memAllocate(unsigned int, void (*)(void *));
void memDump(void);

// call memAllocate and then memDump

int main(void)
{
  int status;

  status = memInitialize(100);
  fprintf(stderr, "calling memInitialize(100), which returns %d\n", status);
  if (status != 1) fprintf(stderr, "FAILURE\n");
  memDump();
  return 0;
}
