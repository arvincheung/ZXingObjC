#import "ReedSolomonDecoderDataMatrixTestCase.h"
#import "ZXGenericGF.h"
#import "ZXReedSolomonDecoder.h"
#import "ZXReedSolomonException.h"

@interface ReedSolomonDecoderDataMatrixTestCase ()

@property (nonatomic, retain) ZXReedSolomonDecoder* dmRSDecoder;

- (void)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen;

@end


@implementation ReedSolomonDecoderDataMatrixTestCase

const int DM_CODE_TEST_LEN = 3;
static int DM_CODE_TEST[DM_CODE_TEST_LEN] = { 142, 164, 186 };

const int DM_CODE_TEST_WITH_EC_LEN = 8;
static int DM_CODE_TEST_WITH_EC[DM_CODE_TEST_WITH_EC_LEN] = { 142, 164, 186, 114, 25, 5, 88, 102 };

const int DM_CODE_ECC_BYTES = DM_CODE_TEST_WITH_EC_LEN - DM_CODE_TEST_LEN;
const int DM_CODE_CORRECTABLE = DM_CODE_ECC_BYTES / 2;

@synthesize dmRSDecoder;

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  if (self = [super initWithInvocation:anInvocation]) {
    self.dmRSDecoder = [[[ZXReedSolomonDecoder alloc] initWithField:[ZXGenericGF DataMatrixField256]] autorelease];
  }

  return self;
}

- (void)dealloc {
  [dmRSDecoder release];

  [super dealloc];
}

- (void)testNoError {
  int receivedLen = DM_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < receivedLen; i++) {
    received[i] = DM_CODE_TEST_WITH_EC[i];
  }
  // no errors
  [self checkQRRSDecode:received receivedLen:receivedLen];
}

- (void)testMaxErrors {
  const int receivedLen = DM_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < DM_CODE_TEST_LEN; i++) {
    for (int i = 0; i < DM_CODE_TEST_WITH_EC_LEN; i++) {
      received[i] = DM_CODE_TEST_WITH_EC[i];
    }
    [self corrupt:received receivedLen:receivedLen howMany:DM_CODE_CORRECTABLE];
    [self checkQRRSDecode:received receivedLen:receivedLen];
  }
}

- (void)testTooManyErrors {
  const int receivedLen = DM_CODE_TEST_WITH_EC_LEN;
  int received[receivedLen];
  for (int i = 0; i < DM_CODE_TEST_WITH_EC_LEN; i++) {
    received[i] = DM_CODE_TEST_WITH_EC[i];
  }
  [self corrupt:received receivedLen:receivedLen howMany:DM_CODE_CORRECTABLE + 1];
  @try {
    [self checkQRRSDecode:received receivedLen:receivedLen];
    STFail(@"Should not have decoded");
  } @catch (ZXReedSolomonException* rse) {
    // good
  }
}

- (void)checkQRRSDecode:(int*)received receivedLen:(int)receivedLen {
  [self.dmRSDecoder decode:received receivedLen:receivedLen twoS:DM_CODE_ECC_BYTES];
  for (int i = 0; i < DM_CODE_TEST_LEN; i++) {
    STAssertEquals(DM_CODE_TEST[i], received[i], @"Expected %d to equal %d", DM_CODE_TEST[i], received[i]);
  }
}

@end
