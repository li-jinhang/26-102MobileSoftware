import { AuthLoginResult } from '../../domain/contracts/AppRepositories';
import { User } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export async function loginWithAccount(account: string, password: string): Promise<User> {
  const result: AuthLoginResult = await repositories.authRepository.login(account, password);
  return result.user;
}

export async function logoutCurrentAccount(): Promise<void> {
  await repositories.authRepository.logout();
}
