const Identity = artifacts.require('Identity');

contract('Identity Test', async (accounts) => {
	const owner = {
		address: '0xD576d0EBA177f8BC9484c3115e7Ab8Fbdbc03C13',
		name: 'John Carter',
		password: '000000',
		type: 'Owner',
	};

	const issuer = {
		address: '0x7ACba9ee3c82A61d8C2c0C5626E4fB496c0a499e',
		name: 'Steve Rogers',
		password: '111111',
		type: 'Issuer',
	};

	const verifier = {
		address: '0xB27039Fbd07B5BA09EbD666BD3A076112c73F61e',
		name: 'Bruce Wayne',
		password: '222222',
		type: 'Verifier',
	};

	it('should create users', async () => {
		const instance = await Identity.deployed();
		await instance.addUser(owner.address, owner.name, owner.password, owner.type);
		let user = await instance.getUser(0);
		assert.equal(user[0], owner.address);
		assert.equal(user[1], owner.name);
		assert.equal(user[2], owner.password);
		assert.equal(user[3], Identity.UserType.Owner);
		// console.log(user);

		await instance.addUser(issuer.address, issuer.name, issuer.password, issuer.type);
		user = await instance.getUser(1);
		assert.equal(user[0], issuer.address);
		assert.equal(user[1], issuer.name);
		assert.equal(user[2], issuer.password);
		assert.equal(user[3], Identity.UserType.Issuer);
		// console.log(user);

		await instance.addUser(verifier.address, verifier.name, verifier.password, verifier.type);
		user = await instance.getUser(2);
		assert.equal(user[0], verifier.address);
		assert.equal(user[1], verifier.name);
		assert.equal(user[2], verifier.password);
		assert.equal(user[3], Identity.UserType.Verifier);
		// console.log(user);
	});

	it('should create credentials by owner', async () => {
		const instance = await Identity.deployed();
		await instance.addCredentials(0, owner.address, issuer.address, 'SSN', 'Social Security Number');
		let credentials = await instance.getCredentialsByOwner(owner.address, '0');
		assert.equal(credentials[1], owner.address);
		assert.equal(credentials[2], issuer.address);
		assert.equal(credentials[3], 'SSN');
		assert.equal(credentials[4], 'Social Security Number');
		// console.log(credentials);
	});

	it('should request credentials by verifier', async () => {
		const instance = await Identity.deployed();
		await instance.requestCredentials(2, 0, 0);
		let revealRecord = await instance.getRevealRecord(owner.address, 0);
		assert.equal(revealRecord[0], owner.address);
		assert.equal(revealRecord[1], verifier.address);
		assert.equal(revealRecord[2], 0);
		assert.equal(revealRecord[3], false);
		// console.log(revealRecord);
	});

	it('should reveal credentials by owner', async () => {
		const instance = await Identity.deployed();
		await instance.revealCredentials(0, 2, 0);
		let revealRecord = await instance.getRevealRecord(owner.address, 1);
		assert.equal(revealRecord[0], owner.address);
		assert.equal(revealRecord[1], verifier.address);
		assert.equal(revealRecord[2], 0);
		assert.equal(revealRecord[3], true);
		// console.log(revealRecord);
	});

	it('should sign credentials by issuer', async () => {
		const instance = await Identity.deployed();
		await instance.signCredentials(0, 1, 0);
		let signRecord = await instance.getSignRecord(owner.address, 0);
		assert.equal(signRecord[0], owner.address);
		assert.equal(signRecord[1], issuer.address);
		assert.equal(signRecord[2], 0);
		assert.equal(signRecord[3], true);
		// console.log(signRecord);
	});

	it('should unsign credentials by issuer', async () => {
		const instance = await Identity.deployed();
		await instance.unSignCredentials(0, 1, 0);
		let signRecord = await instance.getSignRecord(owner.address, 1);
		assert.equal(signRecord[0], owner.address);
		assert.equal(signRecord[1], issuer.address);
		assert.equal(signRecord[2], 0);
		assert.equal(signRecord[3], false);
		// console.log(signRecord);
	});
});
