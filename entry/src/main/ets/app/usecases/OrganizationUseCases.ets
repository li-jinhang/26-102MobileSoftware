import { EmployeeDirectoryItem, OrganizationProfile } from '../../models/AppModels';
import { repositories } from '../repositories/RepositoryProvider';

export async function loadMyOrganizationUseCase(): Promise<OrganizationProfile> {
  return repositories.organizationRepository.getMyOrganization();
}

export async function findEmployeeByIdUseCase(employeeId: string): Promise<EmployeeDirectoryItem | null> {
  const keyword: string = employeeId.trim();
  if (keyword.length === 0) {
    return null;
  }
  const employees: EmployeeDirectoryItem[] = await repositories.organizationRepository.searchUsers('all', keyword);
  const employee: EmployeeDirectoryItem | undefined = employees.find((item: EmployeeDirectoryItem) => item.id === keyword);
  return employee === undefined ? null : employee;
}

export function getDirectReportLabelUseCase(profile: OrganizationProfile): string {
  return profile.directReports.length === 0 ? '暂无直接下属' : `管理 ${profile.directReports.length} 人`;
}

export function sortDepartmentMembersUseCase(items: EmployeeDirectoryItem[]): EmployeeDirectoryItem[] {
  return items.slice().sort((left: EmployeeDirectoryItem, right: EmployeeDirectoryItem) => {
    if (left.jobTitle === right.jobTitle) {
      return left.name.localeCompare(right.name);
    }
    return left.jobTitle.localeCompare(right.jobTitle);
  });
}
