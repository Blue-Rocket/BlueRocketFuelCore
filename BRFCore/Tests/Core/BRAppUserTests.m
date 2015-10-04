//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseTestingSupport.h"

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

- (void)testSame {
	BRAppUser *user = [BRAppUser new];
	user.name = @"n";
	user.email = @"e@e";
	user.firstName = @"f";
	user.lastName = @"l";
	user.uniqueId = @"u";
	user.address = @"a";
	user.website = @"w";
	
	BRAppUser *user2 = [user copy];
	assertThatBool([user isDifferentFrom:user2], isFalse());
}


- (void)testDifferent {
	BRAppUser *user = [BRAppUser new];
	user.name = @"n";
	user.email = @"e@e";
	user.firstName = @"f";
	user.lastName = @"l";
	user.uniqueId = @"u";
	user.address = @"a";
	user.website = @"w";
	
	BRAppUser *user2;
	
	user2 = [user copy];
	user2.name = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
	
	user2 = [user copy];
	user2.email = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
	
	user2 = [user copy];
	user2.firstName = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
	
	user2 = [user copy];
	user2.lastName = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
	
	user2 = [user copy];
	user2.uniqueId = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
	
	user2 = [user copy];
	user2.address = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
	
	user2 = [user copy];
	user2.website = @"!";
	assertThatBool([user isDifferentFrom:user2], isTrue());
}

- (void)testDifferentToNil {
	BRAppUser *user = [BRAppUser new];
	user.email = @"e@e";
	
	BRAppUser *user2;
	
	user2 = [user copy];
	user2.email = nil;
	assertThatBool([user isDifferentFrom:user2], isTrue());
}

@end
