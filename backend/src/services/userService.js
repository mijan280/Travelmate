class UserService {
  constructor(userRepository) {
    this.userRepo = userRepository;
  }

  async getUserById(id) {
    const user = await this.userRepo.findById(id);
    if (!user) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }
    return user.toSafeJSON();
  }

  async updateProfile(id, updates) {
    const allowed = {};
    if (updates.name && typeof updates.name === 'string') {
      allowed.name = updates.name.trim();
    }

    const updated = await this.userRepo.update(id, allowed);
    if (!updated) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }
    return updated.toSafeJSON();
  }
}

module.exports = UserService;
