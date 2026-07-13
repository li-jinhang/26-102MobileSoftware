import { NotificationItem, UserRole } from '../../models/AppModels';

export function getRoleNotifications(items: NotificationItem[], role: UserRole): NotificationItem[] {
  return items.filter((item: NotificationItem) => item.targetRoles.includes(role));
}

export function filterNotifications(items: NotificationItem[], unreadOnly: boolean): NotificationItem[] {
  return unreadOnly ? items.filter((item: NotificationItem) => !item.read) : items;
}

export function markNotificationRead(items: NotificationItem[], notificationId: string): NotificationItem[] {
  return items.map((item: NotificationItem) => {
    const notification: NotificationItem = {
      id: item.id,
      title: item.title,
      content: item.content,
      time: item.time,
      read: item.id === notificationId ? true : item.read,
      targetRoles: item.targetRoles.slice(),
      targetType: item.targetType,
      targetId: item.targetId
    };
    return notification;
  });
}
