# frozen_string_literal: true

RSpec.shared_examples 'a soft destroyable' do |factory_name, **options|
  let(:factory_traits) { options[:factory_traits] }
  let(:dependent_destroy_relations) { options[:dependent_destroy_relations] }

  # we want to access the local variables of the block scope above, which
  # you lose when you enter an instance method scope, but retain when you
  # enter a block scope.
  define_method(:create_instance) do
    create factory_name, *factory_traits
  end

  describe '.kept' do
    it 'only returns records that haven\'t been deleted' do
      # given
      first_destroyable = create_instance
      second_destroyable = create_instance
      first_destroyable.soft_destroy!
      klass = first_destroyable.class
      # when
      remaining = klass.kept
      # then
      expect(remaining).to include(second_destroyable)
      expect(remaining).not_to include(first_destroyable)
    end
  end

  describe '.only_deleted' do
    it 'only returns records that have been deleted' do
      # given
      first_destroyable = create_instance
      second_destroyable = create_instance
      first_destroyable.soft_destroy!
      klass = first_destroyable.class
      # when
      deleted = klass.only_deleted
      # then
      expect(deleted).to include(first_destroyable)
      expect(deleted).not_to include(second_destroyable)
    end
  end

  describe '#soft_destroy!' do
    it 'sets deleted_at' do
      # given
      destroyable = create_instance
      expect(destroyable.deleted_at).to be_nil
      # when
      destroyable.soft_destroy!
      # then
      expect(destroyable.deleted_at).not_to be_nil
    end
    context 'with dependents', if: options[:dependent_destroy_relations]&.present? do
      it 'soft_destroys dependents' do
        # given
        destroyable = create_instance
        dependent_objects = dependent_destroy_relations.map { |relation_name| destroyable.send(relation_name) }.flatten
        dependent_deleted_timestamps = dependent_objects.map(&:deleted_at)
        expect(dependent_deleted_timestamps.compact).to be_empty
        # when
        destroyable.soft_destroy!
        # then
        dependent_deleted_timestamps = dependent_objects.map { |dependent_object| dependent_object.reload.deleted_at }.compact.uniq
        expect(dependent_deleted_timestamps).not_to be_empty
      end
      it 'uses the parent deleted_at timestamp for children' do
        # given
        destroyable = create_instance
        dependent_objects = dependent_destroy_relations.map { |relation_name| destroyable.send(relation_name) }.flatten
        dependent_deleted_timestamps = dependent_objects.map(&:deleted_at)
        expect(dependent_deleted_timestamps.compact).to be_empty
        # when
        destroyable.soft_destroy!
        # then
        dependent_deleted_timestamps = dependent_objects.map { |dependent_object| dependent_object.reload.deleted_at }.compact.uniq
        expect(dependent_deleted_timestamps.size).to eq(1)
        expect(dependent_deleted_timestamps.first).to eq(destroyable.reload.deleted_at)
      end
    end

    it 'raises errors when they are encountered' do
      destroyable = create_instance
      destroyable.define_singleton_method(:update) do |_arg|
        errors.add(:base, 'This record is invalid')
        false
      end
      expect { destroyable.soft_destroy! }.to raise_error(ActiveModel::ValidationError)
    end
  end

  describe 'restore!' do
    it 'clears out deleted_at' do
      # given
      destroyable = create_instance
      destroyable.update(deleted_at: 1.day.ago)
      expect(destroyable.deleted_at).not_to be_nil
      # when
      destroyable.restore!
      # then
      expect(destroyable.deleted_at).to be_nil
    end
    context 'with dependents', if: options[:dependent_destroy_relations]&.present? do
      it 'restores dependents (that were soft_destroyed at the same time)' do
        destroyable = create_instance
        timestamp = 1.day.ago
        destroyable.update(deleted_at: timestamp)
        deleted_associated_objects = []
        dependent_destroy_relations.each do |assoc|
          associated_objects = Array.wrap(destroyable.send(assoc))
          associated_objects.each do |obj|
            obj.update(deleted_at: timestamp)
            deleted_associated_objects << obj
          end
        end
        # when
        destroyable.reload.restore!
        # then
        expect(deleted_associated_objects).not_to be_empty
        deleted_associated_objects.each { |obj| expect(obj.reload).not_to be_soft_destroyed }
      end
      it 'does not restore dependents (when they have different deleted_at timestamps)' do
        destroyable = create_instance
        timestamp = 1.day.ago
        destroyable.update(deleted_at: timestamp)
        associated_objects_that_were_already_deleted = []
        dependent_destroy_relations.each do |assoc|
          associated_objects = Array.wrap(destroyable.send(assoc))
          associated_objects.each do |obj|
            obj.update(deleted_at: 2.days.ago)
            associated_objects_that_were_already_deleted << obj
          end
        end
        # when
        destroyable.reload.restore!
        # then
        expect(associated_objects_that_were_already_deleted).not_to be_empty
        expect(associated_objects_that_were_already_deleted.map(&:reload)).to all be_soft_destroyed
      end
    end

    it 'raises errors when they are encountered' do
      destroyable = create_instance
      destroyable.update(deleted_at: 1.day.ago)
      destroyable.define_singleton_method(:update) do |_arg|
        errors.add(:base, 'This record is invalid')
        false
      end
      expect { destroyable.restore! }.to raise_error(ActiveModel::ValidationError)
    end
  end
end
