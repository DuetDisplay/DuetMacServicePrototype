//
//  DuetServiceProtocol.h
//  DuetServicePrototype
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#ifndef DuetServiceProtocol_h
#define DuetServiceProtocol_h


#endif /* DuetServiceProtocol_h */
@class DuetCoreModel;

@protocol DuetServiceProtocol
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoreModel:(DuetCoreModel *)model;
- (void)startListening;
- (void)stopListening;
@end
