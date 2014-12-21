/*l 
 * Kyle Vickers
 * Prog 5
 *
 * alloc.c
 *
 * This program is for a conservative garbage collector implemented
 * for C
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "string.h"


// *** Perms *** //
void memDump(void);
int memInitialize( unsigned int );
void * memAllocate( unsigned int, void(*finalize)(void*));
static int * heap;
static int heap_length;

// Get registers
int * getEbx( void );
int * getEsi( void );
int * getEdi( void );
int * getEbp( void );
int * getEsp( void );

//static void bug( char*, int );

static int error( char* );
static int parseLength( unsigned int );
static int parseAlloc( unsigned int );
static int parseMark( unsigned int );
static int * heap_begin;



static int * GC_getAllocatedHeader( int * in );
int GC_isAllocated( int * in );
int GC_isInHeap( int * in );
void GC_recurse_marker( int * in );
void GC_mark();
void GC_memFree( int * header );
static void memJoin();
void GC_sweep();


//    Global Variables
//*************************************************/
static const unsigned int ALLOC_BM  =  0x80000000;//
static const unsigned int MARK_BM   =  0x40000000;//
static const unsigned int LENGTH_BM =  0x3FFFFFFF;//

int trig = 0;
extern int __data_start;
extern int _end;
static int esp;//
static int ebp;//
//*************//


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * void *  memInitialize( unsigned int )
 *
 * ( lab )
 * Calls malloc to initialize the state of the system to be one unused
 * block, containing all the space the user requested.
 *
 * PASS: Return 1
 * FAIL: Return 0
 */

int memInitialize( unsigned int size )
{
  if( size <= 0 )
    return error( "size is less than or equal to 0" );
  
  if( heap != NULL )
    return error( "heap is not null" );

  heap = malloc( size * sizeof( unsigned int )  );       
  
  if( heap == NULL )
    return error( "heap failed to initialize" );
 
  // Assign Control Variables
  heap_begin = heap;
  heap_length = size; 
  
  // clear out memory
  int i;
  for( i = 0; i < size; i++ )
  {
    heap[i] = 0;
  }

  // Set up first header [ 0 for finalizer area ]
  heap[0] = ( LENGTH_BM & size );
  heap[1] = 0;
    
  return 1;
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * memAllocate( unsigned int, void(*(finalize)(void*)
 *
 */
void * memAllocate( unsigned int size, void(*finalize)(void*))
{
  fprintf( stderr, "==== memAllocate ====\n" ); 
  int * heap_cur = heap;
  int * smallest = NULL;
  int sa = 0x3FFFFFFF;

  esp = (int)getEsp();
  ebp = (int)getEbp(); 
  
  if( size >= heap_length - 2 )
    return (void*)error( "first Size is greater than allocated memory");

  //Find smallest unallocated block
  int count = 0;
  while( count < heap_length )
  {
    int albit = parseAlloc( *heap_cur );
    if( albit == 0x00000000 )
    {
      if( parseLength( *heap_cur ) <= sa )
      { 
        if( parseLength( *heap_cur ) >= size + 2 )
        {
          sa = parseLength( *heap_cur );
          smallest = heap_cur;
        }
      }
    }

    count += parseLength( *heap_cur );
    heap_cur += parseLength( *heap_cur );
  }

  if( smallest == NULL )
  {
    GC_mark();
    GC_sweep( ); 
    memJoin(); 
    
    if( trig == 0 )
    {
      trig = 1;
      memJoin();
    }
    else
    { 
      return memAllocate( size, finalize );
    }
  }
  else
  {
    int new_ab     = 0x80000000;
    int new_mb     = 0x00000000;
    int new_length = size + 2;
    unsigned int a = new_ab | new_mb | new_length;
    
    // old_length is for free memory info later
    int old_length = parseLength( *smallest );
    // Save return value of user block
    int * retval = smallest + 2;
    
    // Set new header values to the heap 
    *smallest = a;
    *( smallest + 1 ) = (int)finalize; // Is this how you save the finalizer?
     
    // Point to later in the heap and set free memory info
    if( size + 2 < old_length )
    {
      // Create free memory info
      int b = old_length - ( size + 2 );
      unsigned int sb = b << 2;
      b = sb >> 2;
      // Save the new fee memory info
      smallest = smallest + new_length;
      *( smallest ) = b;
    }
    return retval;
  }

  return 0;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * getAllocatedHeader( int *in )
 *
 * Given an address in the heap, this returns the header of the value
 *
 */
int * GC_getAllocatedHeader( int * in )
{
  //fprintf( stderr, "==== getAllocatedHeader ====\n" ); 
  int * heap_cur = heap;
  int * heap_prev = heap_cur;
  while( heap_cur <= &heap[heap_length-1] )
  {
   if( in >= heap_prev && in <= heap_cur )
    {
      return heap_prev;
    }
     
    heap_prev = heap_cur;
    heap_cur += parseLength( *heap_cur );
  }

  return NULL; 
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * void mark();
 * This function marks all the heap that is pointed to by
 * stack, globals, and registers, as well as other secitons of the heap
 */
void GC_mark()
{
  int i;
  int * start = &__data_start;
  int * end = &_end;
  
  while( start < end  )
  { 
     GC_recurse_marker( start ); 
     start++;
  }
  
  //2) Stack Marks
  
  int * cur_ebp = (int*)ebp;
  while( *cur_ebp != 0 )
  {
    cur_ebp = (int*)*cur_ebp;
  }
   
  int * stack_ebp = cur_ebp;
  int * stack_esp = (int*)esp;
 
  i = 0;
  while( stack_esp <= stack_ebp-i )
  {
    if( GC_isInHeap( (int*)*(stack_ebp - i ) ) == 1 )
    { 
      GC_recurse_marker( stack_ebp-i );
    } 
    i++;
  }
  
  //3) Register Marks
  int bx = (int)getEbx();  
  int si = (int) getEsi();  
  int di = (int)getEdi();  
  
  int regs[3];
  regs[0] = bx;
  regs[1] = si;
  regs[2] = di;
  
  for( i = 0; i < 3; i++ )
  { 
    GC_recurse_marker( regs + i );
  } 
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

void GC_recurse_marker( int * in )
{
  if( GC_isInHeap( in ) == 1 )
  { 
    if( GC_isAllocated( in ) == 1 )
    {
      int * header = GC_getAllocatedHeader( (int*)*in ); 
   
        if( parseMark( *header ) == MARK_BM )
        {
          // Already Marked - Base Case - Return
          return;
        }
        else
        {
          // Set the mark in the header to 1
          *header = MARK_BM | *header;
          int i;
          for( i = 2; i < parseLength( *header ); i++ )
          {
            //fprintf( stderr, "header + i: %08x\n",(int*)*(header+i) );
            int * cur = header+i;
            if( cur != 0 )
              GC_recurse_marker( cur );
          }
        }
      }
   }  
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * isAllocated( int * )
 * This takes a pointer to the heap and checks to see if
 * it points to an area that is in an allocated block. 
 * If the pointer is pointing into an allocated block
 * then returns 1
 *
 * if it doesnt point to an allocated block then return 0
 *
 * return -1 if not in heap
 */
int GC_isAllocated( int * in )
{
  
  //fprintf( stderr, "==== GC_isAllocated ====\n" ); 
  
  int * heap_cur = heap;
  int * heap_prev = heap_cur;
  int count = 0;
  int ret;
  while( heap_cur <= &heap[heap_length] )
  {
   if( in >= heap_prev && in <= heap_cur )
    {
      int alloc_bit = parseAlloc( *heap_prev );
      if( alloc_bit == 0x80000000 )
      {
       ret = 1;
      }
      else
      {
        ret = 0;
      }
      
      return ret;
    }

    count += parseLength( *heap_cur );
    heap_prev = heap_cur;
    heap_cur += parseLength( *heap_cur );
  }

  return -1;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * void sweep(  )
 * Does a sweep the heap and checks mark bits
 * if there is a non marked allocated block that is garbage
 * gets rid of it 
 *
 *
 *
 * if largest free block is smaller than the size you are trying to allocate
 */

void GC_sweep( int size )
{
  int count = 0; 
  while( count < heap_length )
  {  
    int alloc_bit = parseAlloc( heap[count] );
    int mark_bit = parseMark( heap[count] );
    int length = parseLength( heap[count] );

    if( alloc_bit == 0x80000000 ) // 1 0
    {
      if( mark_bit == 0x00000000 )
      {
        // Garbage! 

        //(void(*)(void*))(*(heap[count+1])(heap[count+2]));
        

        heap[count] = length; // Check here
      }
      if( mark_bit == 0x40000000 ) // 1 1
      { 
        heap[count] &= 0xBFFFFFFF;
      }
    }
    
    count += length; 
  }  
  
  /*if( largest < size + 2 )
    return 0;
  else
    return 1;*/
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * memJoin()
 * Checks adjacent free blocks to see if they are able to come together
 *
 */
void memJoin()
{
  //fprintf( stderr, "==== memJoin() ====\n" );

  int trigger = 0;

  int * heap_cur = heap;
  int * heap_prev = NULL;

  int i = 0;
  while( i < heap_length )
  {    
    if( heap_prev != NULL )
    { 
      int cur_alloc_bit = parseAlloc( *heap_cur );
      int prev_alloc_bit = parseAlloc( *heap_prev );
      
      if( cur_alloc_bit == 0x00000000 )
      {
        if( prev_alloc_bit == 0x00000000 )
        {
          int curLength = parseLength( *heap_cur );
          int prevLength = parseLength( *heap_prev );
          *heap_prev = curLength + prevLength;
          trigger = 1; 
        } 
      }
    } 
    heap_prev = heap_cur;
    i += parseLength( parseLength( *heap_cur ) );
    heap_cur += parseLength( *heap_cur );
  } 

  if( trigger == 1 )
  {
    memJoin();
  }

  /*
  int x = 0;
  int y = 0;
  while( x < heap_length )
  {
    int ab = parseAlloc( heap[x] );
    int lb = parseLength( heap[x]);
    if( ab == 0 )
    {
      y = x + lb;  
      int next_ab = parseAlloc( heap[y] );
      if( next_ab == 0 )
      {
        heap[x] = x + parseLength( heap[y] ); 
      }
    } 
    x += parseLength( heap[y] );
  }*/
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * isInHeap( int * )
 * returns 0 if the address given is not between the heap's ranges
 * returns 1 if the address is between the heap's ranges
 */
int GC_isInHeap( int * in )
{
  if( in >= heap && in <= &heap[heap_length] )
  {
    return 1;
  }
  else
  {
    return 0;
  }

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * testDump()
 * this is a test function for the heap
 */

void testDump( )
{
  int i;
  for( i = 0; i < heap_length; i++ )
  {
    if( heap[i] == 0 )
      printf( "[%d] %08x   %08x\n",i, heap[i], (int)heap+i );
    else
    { 
      printf(  "---------------------------------\n" );
      printf(  ">> [%d] %08x    %08x\n",i, heap[i], (int)heap + i );
      printf(  ">> [%d] %08x    %08x\n",i + 1, heap[i + 1], (int)heap + i + 1 );
      printf(  "---------------------------------\n" );
      i++;
    }
  }
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * void memDump(void)
 * This function dumps a memory to test the output of Global, Stack,
 * Registers, and Heap memory
 *
 * NOTE: For the heap dump I subtracted 2 from the length stored in the 
 * array to display only the users length of accessible memory. Prof.
 * Hatcher's example output seemed to do the same thing. This works
 * either way, but I'm trying to match the way prof. hatchers slides
 * displayed the length and data.
 */
void memDump()
{
  unsigned int subtrac = &_end - &__data_start;
  int * start = &__data_start;
  int * end = &_end;
  int at_least_one = 0;

  //*heap = 0xBFFFFFFE & *heap; 
  //*(heap + 16) = 0xBFFFFFFF & *(heap + 16 ); 
  //sweep( );
  //testDump();
  //fprintf( stderr, "%08x\n", start );
  //int isalloctest = isAllocated( start );
  //fprintf( stderr, "is alloc test: %d\n", isalloctest );

  //======================== GLOBALS =========================//
  
  fprintf(stderr, "Global Memory: start=%08x end=%08x length=%d\n\n",(int) &__data_start,(int) &_end, subtrac ); 

  while( start < end  )
  { 
    if( start != &heap[0] &&  start != &heap_length )
    {
      if( GC_isInHeap( (int*)*start ) == 1 )
      { 
        if( GC_isAllocated( (int*)*start ) == 1 )
        {
          fprintf( stderr, "%08x %08x\n", (int)start,(int)*start );
          at_least_one = 1;
        }
      }
    } 
    start++;
  }
   
  if( at_least_one == 1 )
    fprintf( stderr, "\n" );
  
  //======================== STACK =========================//
  
  int * cur_ebp = (int*)ebp;
  int atleast = 0;
  while( *cur_ebp != 0 )
  {
    cur_ebp = (int*)*cur_ebp;
  }
  
  int * stack_ebp = cur_ebp;
  int * stack_esp = (int*)esp;
  //int length = (int)end - (int)start;

  fprintf( stderr, "Stack Memory: start=%08x end=%08x length=%d\n\n", ebp, esp, ebp - esp );  
    
  int i = 0;
  while( stack_esp < stack_ebp-i )
  {
    if( GC_isInHeap( (int*)*(stack_ebp - i ) ) == 1 )
    { 
      if( GC_isAllocated( (int*)*(stack_ebp - i ) ) == 1 )
        {
          fprintf( stderr, "%08x %08x\n", (int)( stack_ebp-i ), *(stack_ebp-i) );
          atleast = 1;
        }
    } 
    i++;
  }

  if( atleast == 1 )
    fprintf( stderr, "\n");

  //======================== Regs =========================//

  fprintf( stderr, "Registers\n\n" );
  
  int bx = (int)getEbx();  
  if( GC_isInHeap( (int*)bx ) == 1 ) // Register is in heap
  {
    if( GC_isAllocated( (int*)bx ) == 1 ) // Register is in allocated block 
    {
      fprintf( stderr, "ebx %08x* ", bx );
    }
  }
  else
  {
      fprintf( stderr, "ebx %08x  ", bx );
  }
  
  int si = (int) getEsi();  
  if( GC_isInHeap( (int*)si ) == 1 ) // Register is in heap
  {
    if( GC_isAllocated( (int*)si ) == 1 ) // Register is in allocated block 
    {
      fprintf( stderr, "esi %08x* ", si );
    }
  }
  else
  {
      fprintf( stderr, "esi %08x  ", si );
  }
  
  int di = (int)getEdi();  
  if( GC_isInHeap( (int*)di ) == 1 ) // Register is in heap
  {
    if( GC_isAllocated( (int*)di ) == 1 ) // Register is in allocated block 
    {
      fprintf( stderr, "edi %08x* ", di );
    }
  }
  else
  {
      fprintf( stderr, "edi %08x  ", di );
  }
  
  fprintf(stderr, "\n");

  //======================== Heap =========================//
  fprintf( stderr, "\n" );
  fprintf( stderr, "Heap\n\n");
  
  int * heap_cur = heap;
  int total = 0;
  
  while( total < heap_length )
  {
    int length = parseLength( *heap_cur );
    int ab   = *heap_cur & ALLOC_BM; 
    int mb   = *heap_cur & MARK_BM; 
    
    if( ab == 0x00000000 )
      fprintf( stderr, "Block %d ", length );
    if( ab == 0x80000000 )
      fprintf( stderr, "Block %d ", length - 2 );

    int alcheck = 0;

    // Found unallocated space
    if( ab == 0x00000000 && mb == 0x00000000 )
    {
      fprintf( stderr, "Free " );
      alcheck = 0;
    }
    else
    {
      fprintf( stderr, "Allocated " );
      alcheck = 1;
    }
    
    if( mb == 0x40000000 )
      fprintf( stderr, "Marked %08x\n", *(heap_cur + 1) ); 
    else
      fprintf( stderr, "Unmarked %08x\n", *(heap_cur + 1) );
      
    
    if( alcheck == 1 )
    {
      int a = 0;
      int * cur = heap_cur + 2;
      int i;
      
      for( i = 0; i < length - 2 ; i++ )
      {
        if( i % 7 == 0 )
        {
          fprintf( stderr, "%08x  ",(int) cur ); 
        }

        a++;
        if( GC_isInHeap( (int*)*cur ) == 0 ) // Can't be in heap
          fprintf( stderr, "%08x  ", *cur );
        else
        {
          if( GC_isAllocated( (int*)*cur ) == 1 ) 
            fprintf( stderr, "%08x* ", *cur );
          else 
            fprintf( stderr, "%08x  ", *cur );
        }

        if( a % 7 == 0 )
        {
          fprintf( stderr, "\n" );
        }
        
        cur++;
      } 
    }

    fprintf( stderr, "\n" ); 
    total += length;
    heap_cur += length;
  }
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * parseLength( int )
 * This function, given a 32 bit int, will remove the allocated bit and
 * mark bit and return just the length passed to it
 */
int parseLength( unsigned int whole )
{
   
  if( (LENGTH_BM & whole) == 0x00000000 )
  {
    fprintf( stderr, "!!!!!!!!!!!!\n!! LENGTH IS 0 !!\n!!!!!!!!!!!!\n" );
  }
  return LENGTH_BM & whole;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * parseAllocateBit( int )
 * 
 *
 */
int parseAlloc( unsigned int whole )
{
  return ALLOC_BM & whole;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * parseMark( int )
 */
int parseMark( unsigned int whole )
{
  return MARK_BM & whole;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * error( char* )
 * Prints the string sent to this as an error and then exits the program
 * with a status of exit(-1)
 *
 */
int error( char * str )
{
  fprintf( stderr, "error: %s\n", str );
  return 0;
}
