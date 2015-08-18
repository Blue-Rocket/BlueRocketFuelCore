//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "BaseTestingSupport.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "BRAppUser.h"

@interface BRAppUserTests : BaseTestingSupport

@end

@implementation BRAppUserTests

- (void)testSave {
	BRAppUser *user = [BRAppUser new];
	user.name = @"n";
	user.email = @"e@e";
	user.password = @"p";
	user.passwordAgain = @"p";
	
	BRAppUser *active = [BRAppUser currentUser];
	assertThat(active, notNilValue());
	assertThat(user, isNot(sameInstance(active)));
	
	[BRAppUser replaceCurrentUser:user];
	
	active = [BRAppUser currentUser];
	assertThat(user, sameInstance(active));
	assertThat(active.name, equalTo(@"n"));
	assertThat(active.email, equalTo(@"e@e"));
	assertThat(active.password, equalTo(@"p"));
	assertThat(active.passwordAgain, nilValue());
}

@end
