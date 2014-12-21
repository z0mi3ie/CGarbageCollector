#include <stdio.h>
int memInitialize(unsigned int);
void *memAllocate(unsigned int, void (*)(void *));
void memDump(void);

// test repeated memAllocate calls, until the heap is fully used
// place returned pointers into globals, locals and heap

int *globalPtr;

int main(void)
{
  int status;
  int *ptr[10];

  status = memInitialize(100);
  fprintf(stderr, "calling memInitialize(100), which returns %d\n", status);
  if (status != 1) fprintf(stderr, "FAILURE\n");
  else
  { 
    int i;

    globalPtr = memAllocate(15, 0);
    
    
    memAllocate( 15, 0 );//memAllocate( 15, 0 );
    //memAllocate( 15, 0 );//memAllocate( 15, 0 );
    //memAllocate( 15, 0 );//memAllocate( 15, 0 );

   // testDump();
    //memAllocate( 15, 0 );
    //memAllocate( 15, 0 );
    
    
    fprintf(stderr, "calling memAllocate(15, 0), which returns %p\n", globalPtr );
    for (i = 0; i < 3; i++)
    {
      ptr[i] = memAllocate(15, 0);
      
      fprintf(stderr, "calling memAllocate(15, 0), which returns %p\n", ptr[i]);
    }
    
    //globalPtr[2] = (int)ptr[2];
    //ptr[1][1] = (int) ptr[1];
    //ptr[1][3] = (int) ptr[1];
    //ptr[2][2] = (int) ptr[2];
    //ptr[3][3] = (int) ptr[3];
    //ptr[10] = memAllocate(15,0);
    
    //testDump();
    //testDump();  
    memDump();
    //testDump(); 
    /*
    int test = 0x10b37849;
    int * testPtr = &test;

    fprintf( stderr, "pre   memFree test %08x ", *testPtr );  

    //GC_memFree( &(*testPtr) );
    fprintf( stderr, "after memFree test %08x ", *testPtr ); */
  
  }

  return 0;
}

