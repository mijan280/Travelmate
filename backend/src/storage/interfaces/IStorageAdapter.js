/**
 * Storage Adapter Interface
 * 
 * Defines the contract that all storage implementations must satisfy.
 * Future adapters (e.g., MongoStorageAdapter, MySqlStorageAdapter, PostgresStorageAdapter)
 * implement these exact methods, allowing seamless database migration without modifying
 * repositories, services, controllers, or Flutter client code.
 */
class IStorageAdapter {
  async read(collectionName) {
    throw new Error('Method read() must be implemented.');
  }

  async write(collectionName, items) {
    throw new Error('Method write() must be implemented.');
  }

  async find(collectionName, predicate) {
    throw new Error('Method find() must be implemented.');
  }

  async findOne(collectionName, predicate) {
    throw new Error('Method findOne() must be implemented.');
  }

  async findById(collectionName, id) {
    throw new Error('Method findById() must be implemented.');
  }

  async insert(collectionName, item) {
    throw new Error('Method insert() must be implemented.');
  }

  async update(collectionName, id, updates) {
    throw new Error('Method update() must be implemented.');
  }

  async delete(collectionName, id) {
    throw new Error('Method delete() must be implemented.');
  }
}

module.exports = IStorageAdapter;
