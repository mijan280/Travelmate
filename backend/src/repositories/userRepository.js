const User = require('../models/User');

class UserRepository {
  constructor(storageAdapter) {
    this.storage = storageAdapter;
    this.collection = 'users';
  }

  async findById(id) {
    const raw = await this.storage.findById(this.collection, id);
    return raw ? new User(raw) : null;
  }

  async findByEmail(email) {
    const raw = await this.storage.findOne(
      this.collection,
      (user) => user.email && user.email.toLowerCase() === email.toLowerCase()
    );
    return raw ? new User(raw) : null;
  }

  async findAll() {
    const list = await this.storage.read(this.collection);
    return list.map((item) => new User(item));
  }

  async create(userData) {
    const created = await this.storage.insert(this.collection, userData);
    return new User(created);
  }

  async update(id, updates) {
    const updated = await this.storage.update(this.collection, id, updates);
    return updated ? new User(updated) : null;
  }

  async delete(id) {
    return this.storage.delete(this.collection, id);
  }
}

module.exports = UserRepository;
